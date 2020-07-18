//
//  Downloader.swift
//  iOS
//
//  Created by Gabriel Soria Souza on 15/07/20.
//

import SwiftUI

final class Downloader: ObservableObject, ServiceDelegate {
    
    let service = Service()
    var filesManager: FilesProtocol?
    @Published var downloadsInProgress: [Download] = []
    
    init() {
        self.service.delegate = self
    }
    
    func downloadFileFromService(urlString: String) {
        guard let url = URL(string: urlString) else {
            //not valid url
            return
        }
        self.service.fileDownloader(from: urlString, with: url.lastPathComponent)
    }
    
    func didStartDownloadingFile(_ file: Download) {
        self.downloadsInProgress.insert(file, at: 0)
    }
    
    func didFinishDownloadingFile(to url: URL, temporaryLocation: String, withName: String, _ file: Download?) {
        self.filesManager?.saveFile(url: url, fileName: temporaryLocation)
        let fileToBeDeleted = self.downloadsInProgress.firstIndex { item in
            item.track == file?.track
        }
        if let idx = fileToBeDeleted {
            self.downloadsInProgress.remove(at: idx)
            self.filesManager?.saveFile(url: url, fileName: temporaryLocation)
        }
    }
    
    func downloadInProgress(_ file: Download, bytesNowWritten: Int64, totalWritten: Int64, totalToBeWritten: Int64) {
        let fileToBeUpdated = self.downloadsInProgress.firstIndex { item in
            item.track == file.track
        }
        
        if let idx = fileToBeUpdated {
            let item = self.downloadsInProgress[idx]
            item.isDownloading = file.isDownloading
            item.progress = file.progress
            item.resumeData = file.resumeData
            item.task = file.task
            item.track = file.track
            self.downloadsInProgress[idx] = item
        }
    }
}
