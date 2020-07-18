//
//  Service.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import Combine
import Foundation

final class DownloadService {
    
    var activeDownloads: [URL: Download] = [:]
    var downloadSession: URLSession?
    
    func cancelDownload(_ track: Track) {
        guard let download = activeDownloads[track.url] else {
            return
        }
        download.task?.cancel()
        activeDownloads[track.url] = nil
    }
    
    func pauseDownload(_ track: Track) {
        guard let download = activeDownloads[track.url], download.isDownloading else {
            return
        }
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        
        download.isDownloading = false
    }
    
    func resumeDownload(_ track: Track) {
        guard let download = activeDownloads[track.url] else {
            return
        }
        
        if let resumeData = download.resumeData {
            download.task = downloadSession?.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadSession?.downloadTask(with: download.track.url)
        }
        download.task?.resume()
        download.isDownloading = true
    }
    
    func startDownloading(_ track: Track) {
        if self.downloadSession?.configuration.identifier == track.name {
            self.cancelDownload(track)
        }
        let download = Download(track: track)
        download.task = self.downloadSession?.downloadTask(with: track.url)
        download.task?.resume()
        download.isDownloading = true
        activeDownloads[download.track.url] = download
    }
}

protocol ServiceDelegate: AnyObject {
    func didStartDownloadingFile(_ file: Download)
    func didFinishDownloadingFile(to url: URL, temporaryLocation: String, withName: String, _ file: Download?)
    func downloadInProgress(_ file: Download, bytesNowWritten: Int64, totalWritten: Int64, totalToBeWritten: Int64)
}

protocol ServiceProtocol {
    var delegate: ServiceDelegate? { get set }
    func fileDownloader(from url: String, with name: String)
}

final class Service: NSObject, ServiceProtocol, URLSessionDelegate, URLSessionDownloadDelegate {
    
    //var session: URLSession?
    //var downloadTask: URLSessionDownloadTask?
    weak var delegate: ServiceDelegate?
    var downloadService: DownloadService?
    
    func fileDownloader(from url: String, with name: String) {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: name)
        sessionConfiguration.sessionSendsLaunchEvents = true
        sessionConfiguration.isDiscretionary = true
        
        let queue = OperationQueue()
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
        guard let theURL = URL(string: url) else { return }
        
        self.downloadService = DownloadService()
        self.downloadService?.downloadSession = session
        self.downloadService?.startDownloading(Track(name: name, artist: String(), url: theURL))
        
        guard let service = downloadService?.activeDownloads[theURL] else { return }
        
        DispatchQueue.main.async {
            self.delegate?.didStartDownloadingFile(service)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        DispatchQueue.main.async {
            
            guard
              let url = downloadTask.originalRequest?.url,
                let download = self.downloadService?.activeDownloads[url]  else {
                return
            }
            
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            self.delegate?.downloadInProgress(download, bytesNowWritten: bytesWritten, totalWritten: totalBytesWritten, totalToBeWritten: totalBytesExpectedToWrite)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
          return
        }
        
        let download = downloadService?.activeDownloads[sourceURL]
        downloadService?.activeDownloads[sourceURL] = nil
        
        DispatchQueue.main.async {
            self.delegate?.didFinishDownloadingFile(to: location, temporaryLocation: session.configuration.identifier ?? String(), withName: session.configuration.identifier ?? String(), download)
        }
    }
}
