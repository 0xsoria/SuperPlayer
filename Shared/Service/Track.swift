//
//  Track.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 12/07/20.
//

import Foundation

final class Track: Equatable, Hashable {
    
    let artist: String
    //let index: Int
    let name: String
    var url: URL
    var downloaded = false
    
    init(name: String, artist: String, url: URL) {
        self.name = name
        self.artist = artist
        self.url = url
        //self.index = index
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.artist == rhs.artist && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(artist)
    }
}
