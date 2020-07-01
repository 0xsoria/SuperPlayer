//
//  Service.swift
//  SuperPlayer
//
//  Created by Gabriel Sória Souza on 22/06/20.
//

import Foundation

protocol ServiceDelegate: AnyObject {
    func didStartDownloadingFile(_ service: ServiceProtocol)
    func didFinishDownloadingFile(to url: URL, temporaryLocation: String, withName: String, _ service: ServiceProtocol)
    func didStartDownloading(_ service: ServiceProtocol, bytesNowWritten: Int64, totalWritten: Int64, totalToBeWritten: Int64)
}

protocol ServiceProtocol {
    var delegate: ServiceDelegate? { get set }
    func fileDownloader(from url: String, with name: String)
}

final class Service: NSObject, ServiceProtocol, URLSessionDelegate, URLSessionDownloadDelegate {

    private var session: URLSession?
    var downloadTask: URLSessionDownloadTask?
    weak var delegate: ServiceDelegate?
    
    func fileDownloader(from url: String, with name: String) {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: name)
        sessionConfiguration.sessionSendsLaunchEvents = true
        sessionConfiguration.isDiscretionary = true
        
        let queue = OperationQueue()
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
        guard let theURL = URL(string: url) else { return }
        
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
        
        let downloadTask = session.downloadTask(with: theURL)
        self.downloadTask = downloadTask
        downloadTask.resume()
        
        self.delegate?.didStartDownloadingFile(self)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if self.downloadTask == downloadTask {
            print(bytesWritten)
            print(totalBytesWritten)
            print(totalBytesExpectedToWrite)
            self.delegate?.didStartDownloading(self, bytesNowWritten: bytesWritten, totalWritten: totalBytesWritten, totalToBeWritten: totalBytesExpectedToWrite)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {

    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("did become invalid")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("finished events for background session")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.delegate?.didFinishDownloadingFile(to: location, temporaryLocation: session.configuration.identifier ?? String(), withName: self.session?.configuration.identifier ?? "tempname", self)
        session.finishTasksAndInvalidate()
    }
}
