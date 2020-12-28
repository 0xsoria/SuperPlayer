//
//  DownloadService.swift
//  iOS
//
//  Created by Gabriel Sória on 25/07/20.
//

import Foundation

protocol ServiceDelegate: AnyObject {
	func didStartDownloadingFile(_ file: Download)
	func didFinishDownloadingFile(to url: URL, temporaryLocation: String, withName: String, _ file: Download?)
	func downloadInProgress(_ file: Download, bytesNowWritten: Int64, totalWritten: Int64, totalToBeWritten: Int64)
}

final class DownloadServiceMock: NSObject, Downloadable {
	var session: URLSession?
	var downloads: [Download] = []
	weak var delegate: ServiceDelegate?
	
	func fileDownloader(from url: String, with name: String) {
		guard let url = URL(string: url) else { return }
		self.startDownloading(track: Track(name: name, artist: String(), url: url))
	}
	
	func startDownloading(track: Track) {
		let download = Download(track: track)
		download.isDownloading = true
		self.downloads.insert(download, at: 0)
		DispatchQueue.main.async { [weak self] in
			self?.delegate?.didStartDownloadingFile(download)
		}
		for i in 0...100 {
			self.downloadProgress(download: download, loop: i)
		}
	}
	
	private func downloadProgress(download: Download, loop: Int) {
		self.delay(2.0, closure: {
			if download.progress < 0.99 {
				download.progress += 0.01
				self.delegate?.downloadInProgress(download, bytesNowWritten: 1, totalWritten: Int64(loop), totalToBeWritten: 100)
			} else {
				self.downloads.removeAll { item -> Bool in
					self.delegate?.didFinishDownloadingFile(to: FilesManager.savingFolder()!, temporaryLocation: String(), withName: download.track.name, download)
					return item.track == download.track
				}
			}
		})
	}
	
	private func delay(_ delay:Double, closure:@escaping () -> ()) {
		let when = DispatchTime.now() + delay
		DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
	}
	
	func cancelDownload(track: Track) {
		//
	}
}

protocol Downloadable: class {
	var session: URLSession? { get set }
	var downloads: [Download] { get set }
	var delegate: ServiceDelegate? { get set }
	
	func fileDownloader(from url: String, with name: String)
	func startDownloading(track: Track)
	func cancelDownload(track: Track)
}

final class DownloadService: NSObject, Downloadable {
	
	var session: URLSession?
	var downloads = [Download]()
	weak var delegate: ServiceDelegate?
	
	func fileDownloader(from url: String, with name: String) {
		let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: name)
		sessionConfiguration.sessionSendsLaunchEvents = true
		sessionConfiguration.isDiscretionary = true
		let queue = OperationQueue()
		self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
		
		guard let url = URL(string: url) else { return }
		self.startDownloading(track: Track(name: name, artist: String(), url: url))
	}
	
	func startDownloading(track: Track) {
		if self.session?.configuration.identifier == track.name {
			self.cancelDownload(track: track)
		}
		let download = Download(track: track)
		download.task = self.session?.downloadTask(with: track.url)
		download.isDownloading = true
		download.task?.resume()
		self.downloads.insert(download, at: 0)
		DispatchQueue.main.async { [weak self] in
			self?.delegate?.didStartDownloadingFile(download)
		}
	}
	
	func cancelDownload(track: Track) {
		let download = self.downloads.first { item in
			item.track.url == track.url
		}
		
		guard let itemToBeCanceled = download else { return }
		
		guard let index = self.downloads.firstIndex(of: itemToBeCanceled) else { return }
		self.downloads.remove(at: index)
	}
}

extension DownloadService: URLSessionDelegate, URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		
		
		guard let sourceURL = downloadTask.originalRequest?.url else {
			return
		}
		
		let download = self.downloads.first { item in
			item.track.url == sourceURL
		}
		
		guard let itemToBeDeleted = download else { return }
		self.delegate?.didFinishDownloadingFile(to: location,
												temporaryLocation: session.configuration.identifier ?? String(),
												withName: session.configuration.identifier ?? String(),
												itemToBeDeleted)
		
		guard let index = self.downloads.firstIndex(of: itemToBeDeleted) else { return }
		self.downloads.remove(at: index)
		
	}
	
	func urlSession(_ session: URLSession,
					downloadTask: URLSessionDownloadTask,
					didWriteData bytesWritten: Int64,
					totalBytesWritten: Int64,
					totalBytesExpectedToWrite: Int64) {
		
		DispatchQueue.main.async {
			guard
				let sourceURL = downloadTask.originalRequest?.url else {
				return
			}
			
			let download = self.downloads.first { item in
				item.track.url == sourceURL
			}
			
			guard let itemToBeUpdated = download else { return }
			itemToBeUpdated.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
			
			guard let index = self.downloads.firstIndex(of: itemToBeUpdated) else { return }
			
			self.downloads[index].progress = itemToBeUpdated.progress
			
			self.delegate?.downloadInProgress(itemToBeUpdated, bytesNowWritten: bytesWritten, totalWritten: totalBytesWritten, totalToBeWritten: totalBytesExpectedToWrite)
		}
	}
	
	func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
		print(error)
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		print(session)
	}
}
