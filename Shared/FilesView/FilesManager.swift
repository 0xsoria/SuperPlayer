//
//  FilesManager.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import Foundation
import Combine

protocol FilesProtocol {
    var files: [URL] { get set }
    
    func loadFile(at index: Int) -> URL?
    func loadFiles()
    func deleteFilesAt(index: Int)
    func saveFile(url: URL, fileName: String)
    func downloadFileFromService(urlString: String)
}

final class FilesManager: ObservableObject, FilesProtocol {
    
    @Published var files: [URL] = [] {
        didSet {
            didChange.send(self)
        }
    }
    var service: ServiceProtocol
    var didChange = PassthroughSubject<FilesManager, Never>()
    
    init(service: ServiceProtocol) {
        self.service = service
        self.service.delegate = self
    }
    
    private func userFolder() -> [URL] {
        let filesManager = FileManager.default
        let url = filesManager.urls(for: .documentDirectory, in: .userDomainMask)
        return url
    }
    
    func loadFile(at index: Int) -> URL? {
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
            self.files = returnData
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
            let fileData = try Data(contentsOf: url)
            let url = urlPath.appendingPathComponent(fileName)
            fm.createFile(atPath: url.path, contents: fileData, attributes: nil)
            
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
        guard let url = URL(string: urlString) else { return }
        self.service.fileDownloader(from: urlString, with: url.lastPathComponent)
    }
}

extension FilesManager: ServiceDelegate {
    func didStartDownloadingFile(_ service: ServiceProtocol) {
        print("started")
    }
    
    func didFinishDownloadingFile(to url: URL, temporaryLocation: String, withName: String, _ service: ServiceProtocol) {
        self.saveFile(url: url, fileName: temporaryLocation)
    }
    
    func didStartDownloading(_ service: ServiceProtocol, bytesNowWritten: Int64, totalWritten: Int64, totalToBeWritten: Int64) {
        print("just wrote \(bytesNowWritten) total wrote \(totalWritten) to be written \(totalToBeWritten)")
    }
}
