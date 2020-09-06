//
//  MetadataContent.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 06/09/20.
//

import Foundation

final class MetadataContent {
	let key: String
	let value: String
	
	init(key: String, value: String) {
		self.key = key
		self.value = value
	}
}

extension MetadataContent: Equatable, Hashable, Identifiable {
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(key)
		hasher.combine(value)
	}
	
	static func ==(lhs: MetadataContent, rhs: MetadataContent) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
