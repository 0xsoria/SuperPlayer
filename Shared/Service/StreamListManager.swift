//
//  StreamListManager.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 08/08/20.
//

import Foundation

final class StreamListManager {
	
	static let shared = StreamListManager()
	var streams = [Stream]()
	private var streamMap = [String: Stream]()
	
	func stream(with name: String) -> Stream {
		guard let stream = streamMap[name] else {
			fatalError()
		}
		return stream
	}
}
