//
//  AssetPersistenceManager.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 08/08/20.
//

import Foundation
import AVFoundation

final class AssetPersistenceManager: NSObject {
	
	static let sharedManager = AssetPersistenceManager()
	private var didRestorePersistenceManager = false
	fileprivate var assetDownloadURLSession: AVAssetDownloadURLSession?
	fileprivate var activeDownloadsMap = [AVAggregateAssetDownloadTask: Asset]()
	fileprivate var willDownloadToURLMap = [AVAggregateAssetDownloadTask: URL]()
	
	override private init() {
		super.init()
		let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "SS-ID")
		assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
	}
	
	func restorePersistenceManager() {
		guard !didRestorePersistenceManager else { return }
		
		didRestorePersistenceManager = true
		
		assetDownloadURLSession?.getAllTasks(completionHandler: { taskArray in
			for task in taskArray {
				guard let assetDownloadTask = task as? AVAggregateAssetDownloadTask, let assetName = task.taskDescription else { break }
				let stream = StreamListManager.shared.stream(with: assetName)
				let urlAsset = assetDownloadTask.urlAsset
				let asset = Asset(stream: stream, urlAsset: urlAsset)
				self.activeDownloadsMap[assetDownloadTask] = asset
			}
			NotificationCenter.default.post(name: .AssetPersistenceManagerDidRestoreState, object: nil)
		})
	}
	
	func downloadStream(for asset: Asset) {
		let preferredMediaSelection = asset.urlAsset.preferredMediaSelection
		
		guard let task = assetDownloadURLSession?
				.aggregateAssetDownloadTask(with: asset.urlAsset,
											mediaSelections: [preferredMediaSelection],
											assetTitle: asset.stream.name,
											assetArtworkData: nil,
											options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey : 265_000]) else { return }
		task.taskDescription = asset.stream.name
		task.resume()
		
		var userInfo = [String: Any]()
		userInfo[Asset.Keys.name] = asset.stream.name
		userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading.rawValue
		userInfo[Asset.Keys.downloadSelectionDisplayName] = self.displayNamesForSelectedMediaOptions(preferredMediaSelection)
		
		NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
	}
	
	func assetForStream(with name: String) -> Asset? {
		var asset: Asset?
		
		for (_, assetValue) in self.activeDownloadsMap where name == assetValue.stream.name {
			asset = assetValue
			break
		}
		
		return asset
	}
	
	func localAssetForStream(with name: String) -> Asset? {
		nil
	}
	
	func downloadState(for asset: Asset) -> Asset.DownloadState {
		if let localFileLocation = localAssetForStream(with: asset.stream.name)?.urlAsset.url {
			if FileManager.default.fileExists(atPath: localFileLocation.path) {
				return .downloaded
			}
		}
		
		for (_, assetValue) in activeDownloadsMap where asset.stream.name == assetValue.stream.name {
			return .downloading
		}
		
		return .notDownloaded
	}
	
	func deleteAsset(_ asset: Asset) {
		let userDefaults = UserDefaults.standard
		do {
			if let localFileLocation = localAssetForStream(with: asset.stream.name)?.urlAsset.url {
				try FileManager.default.removeItem(at: localFileLocation)
				userDefaults.removeObject(forKey: asset.stream.name)
				
				var userInfo = [String: Any]()
				userInfo[Asset.Keys.name] = asset.stream.name
				userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
				
				NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
			}
		} catch {
			print("could not delete \(error)")
		}
	}
	
	
	func displayNamesForSelectedMediaOptions(_ mediaSelection: AVMediaSelection) -> String {
		var displayNames = String()
		guard let asset = mediaSelection.asset else { return displayNames }
		for mediaCharacteristic in asset.availableMediaCharacteristicsWithMediaSelectionOptions {
			guard let mediaSelectionGroup =
					asset.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic),
				  let option = mediaSelection.selectedMediaOption(in: mediaSelectionGroup) else { continue }
			
			if displayNames.isEmpty {
				displayNames += " " + option.displayName
			} else {
				displayNames += ", " + option.displayName
			}
		}
		return displayNames
	}
	
	func cancelDownload(for asset: Asset) {
		var task: AVAggregateAssetDownloadTask?
		
		for (taskKey, assetVal) in activeDownloadsMap where asset == assetVal {
			task = taskKey
			break
		}
		task?.cancel()
	}
}

extension AssetPersistenceManager: AVAssetDownloadDelegate {
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		let userDefaults = UserDefaults.standard
		
		guard let task = task as? AVAggregateAssetDownloadTask,
			  let asset = activeDownloadsMap.removeValue(forKey: task) else { return }
		
		guard let downloadURL = willDownloadToURLMap.removeValue(forKey: task) else { return }
		
		var userInfo = [String: Any]()
		userInfo[Asset.Keys.name] = asset.stream.name
		
		if let error = error as NSError? {
			switch (error.domain, error.code) {
			case (NSURLErrorDomain, NSURLErrorCancelled):
				guard let localFileLocation = localAssetForStream(with: asset.stream.name)?.urlAsset.url else { return }
				do {
					try FileManager.default.removeItem(at: localFileLocation)
					userDefaults.removeObject(forKey: asset.stream.name)
				} catch {
					print("error occured trying to delete the contents of disk for \(asset.stream.name): \(error)")
				}
				userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
			case (NSURLErrorDomain, NSURLErrorUnknown):
				fatalError()
			default:
				fatalError()
			}
		} else {
			do {
				let bookmark = try downloadURL.bookmarkData()
				userDefaults.setValue(bookmark, forKey: asset.stream.name)
			} catch {
				print("failed to create bookmark data")
			}
			
			userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloaded.rawValue
			userInfo[Asset.Keys.downloadSelectionDisplayName] = String()
		}
		NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
	}
	
	func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didCompleteFor mediaSelection: AVMediaSelection) {
		guard let asset = activeDownloadsMap[aggregateAssetDownloadTask] else { return }
		
	}
}


extension Notification.Name {
	/// Notification for when download progress has changed.
	static let AssetDownloadProgress = Notification.Name(rawValue: "AssetDownloadProgressNotification")
	
	/// Notification for when the download state of an Asset has changed.
	static let AssetDownloadStateChanged = Notification.Name(rawValue: "AssetDownloadStateChangedNotification")
	
	/// Notification for when AssetPersistenceManager has completely restored its state.
	static let AssetPersistenceManagerDidRestoreState = Notification.Name(rawValue: "AssetPersistenceManagerDidRestoreStateNotification")
}
