//
//  MetadataContent.swift
//  SuperPlayer
//
//  Created by Gabriel Soria Souza on 06/09/20.
//

import Foundation

struct MetadataContent: Hashable {
	let key: String
	let value: String
}

extension MetadataContent: Equatable {
	static func ==(lhs: MetadataContent, rhs: MetadataContent) -> Bool {
		lhs.key > rhs.key
	}
}
