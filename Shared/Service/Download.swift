//
//  Download.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 12/07/20.
//

import Combine
import Foundation
import SwiftUI

final class Download: Equatable, Hashable, Identifiable, ObservableObject {
    
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var track: Track
    
    init(track: Track) {
        self.track = track
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(resumeData)
        hasher.combine(track)
        hasher.combine(task)
    }
    
    static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.isDownloading == rhs.isDownloading && lhs.track == rhs.track
    }
}
