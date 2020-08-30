//
//  Stream.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 08/08/20.
//

import AVFoundation

final class Stream: Codable {
	let name: String
	let playlistURL: String
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case playlistURL = "playlist_url"
	}
}

extension Stream: Equatable {
	static func == (lhs: Stream, rhs: Stream) -> Bool {
		(lhs.name == rhs.name) && (lhs.playlistURL == rhs.playlistURL)
	}
}
