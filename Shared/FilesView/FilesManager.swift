//
//  FilesManager.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import Foundation
import Combine

protocol FilesProtocol {
    var files: [Track] { get set }
    
    func loadFile(at index: Int) -> Track?
    func loadFiles()
    func deleteFilesAt(index: Int)
    func saveFile(url: URL, fileName: String)
    func downloadFileFromService(urlString: String)
}

final class FilesManager: ObservableObject, FilesProtocol {
    
    @Published var files: [Track] = [] {
        didSet {
            didChange.send(self)
        }
    }
    private var didChange = PassthroughSubject<FilesManager, Never>()
    @Published var downloadsInProgress: [Download] = []
    private let service = DownloadService()
    
    private func userFolder() -> [URL] {
        let filesManager = FileManager.default
        let url = filesManager.urls(for: .documentDirectory, in: .userDomainMask)
        return url
    }
    
    func loadFile(at index: Int) -> Track? {
        self.loadFiles()
        guard self.files.count >= index else { return nil }
        let file = self.files[index]
        return file
    }
    
    func loadFiles() {
        let urls = self.userFolder().first
        do {
            guard let url = urls else { return }
            let returnData = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            self.files = returnData.map {
                Track(name: $0.lastPathComponent, artist: String(), url: $0)
            }
        } catch {
            self.files = []
        }
    }
        
    func deleteFilesAt(index: Int) {
        let fileManager = FileManager.default
        
        guard let url = self.userFolder().first else { return }
        do {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let file = files[index]
            try fileManager.removeItem(at: file)
            
            DispatchQueue.main.async {
                self.loadFiles()
            }
            
        } catch {
            DispatchQueue.main.async {
                //could not delete the file
            }
        }
    }
    
    func saveFile(url: URL, fileName: String) {
        let fm = FileManager.default
        guard let urlPath = self.userFolder().first else { return }
        
        do {
            let newURL = urlPath.appendingPathComponent(fileName)
            let fileData = try Data(contentsOf: url)
            fm.createFile(atPath: newURL.path, contents: fileData, attributes: nil)
            
            DispatchQueue.main.async {
                self.loadFiles()
            }
            
        } catch {
            DispatchQueue.main.async {
                //could not get data
            }
        }
    }
    
    func downloadFileFromService(urlString: String) {
        guard let url = URL(string: urlString) else {
            //not valid url 
            return
        }
        self.service.delegate = self
        self.service.fileDownloader(from: urlString, with: url.lastPathComponent)
    }
}

extension FilesManager: ServiceDelegate {
    func didStartDownloadingFile(_ file: Download) {
        self.downloadsInProgress.insert(file, at: 0)
    }
    
    func didFinishDownloadingFile(to url: URL, temporaryLocation: String, withName: String, _ file: Download?) {
        self.saveFile(url: url, fileName: temporaryLocation)
        let fileToBeDeleted = self.downloadsInProgress.firstIndex { item in
            item.track == file?.track
        }
        if let idx = fileToBeDeleted {
            //self.downloadsInProgress.remove(at: idx)
            //self.saveFile(url: url, fileName: temporaryLocation)
        }
    }
    
    func downloadInProgress(_ file: Download, bytesNowWritten: Int64, totalWritten: Int64, totalToBeWritten: Int64) {
        print(bytesNowWritten)
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
