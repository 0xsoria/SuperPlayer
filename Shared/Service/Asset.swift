//
//  Asset.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 08/08/20.
//

import AVFoundation

final class Asset {
	var urlAsset: AVURLAsset
	let stream: Stream
	
	init(stream: Stream, urlAsset: AVURLAsset) {
		self.urlAsset = urlAsset
		self.stream = stream
	}
	
	enum DownloadState: String {
		case notDownloaded
		case downloading
		case downloaded
	}
	
	struct Keys {
		static let name = "AssetNameKey"
		static let percentDownloaded = "AssetPercentDownloadedKey"
		static let downloadState = "AssetDownloadStateKey"
		static let downloadSelectionDisplayName = "AssetDownloadSelectionDisplayNameKey"
	}
}

extension Asset: Equatable {
	static func == (lhs: Asset, rhs: Asset) -> Bool {
		(lhs.stream == rhs.stream) && (lhs.urlAsset == rhs.urlAsset)
	}
}
