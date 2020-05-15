//
//  F4SDownloadService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking
import WorkfinderServices

public protocol F4SDownloadServiceDelegate  {
    func downloadService(_ service: F4SDownloadService, didFinishDownloadingToUrl: URL)
    func downloadService(_ service: F4SDownloadService, didFailToDownloadWithError: WorkfinderError)
    func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double)
    func downloadServiceFinishedBackgroundSession(_ service: F4SDownloadService)
}

public protocol F4SDownloadServiceProtocol {
    var sessionIdentifier: String { get }
    func startDownload(from url: URL)
    func cancel()
}

public class F4SDownloadService : NSObject, F4SDownloadServiceProtocol {
    
    public private (set) var isDownloading: Bool
    
    private var downloadTask: URLSessionDownloadTask? = nil
    private var delegate: F4SDownloadServiceDelegate
    
    private lazy var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.background(withIdentifier: F4SDownloadService.sessionIdentifier)
        
        configuration.allowsCellularAccess = true
        configuration.sessionSendsLaunchEvents = true
        configuration.waitsForConnectivity = true
        return configuration
    }()
    
    public static var sessionIdentifier: String {
        return "F4SBackgroundDownloadSession.companyDatabase"
    }
    
    public var sessionIdentifier: String {
        return F4SDownloadService.sessionIdentifier
    }
    
    private lazy var downloadsSession: URLSession = {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    public init(delegate: F4SDownloadServiceDelegate) {
        self.delegate = delegate
        self.isDownloading = false
        super.init()
        _ = downloadsSession
    }
    
    public func startDownload(from url: URL) {
        cancel()
        let task = downloadsSession.downloadTask(with: url)
        downloadTask = task
        task.resume()
        isDownloading = true
    }
    
    public func cancel() {
        defer { isDownloading = false }
        guard let task = downloadTask else { return }
        task.cancel()
    }
}

// MARK:- URLSessionDownloadDelegate
extension F4SDownloadService : URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let attempting = "Background download"
        defer { self.downloadTask = nil }
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse  else {
            let error = WorkfinderError(errorType: .noData, attempting: attempting, retryHandler: nil)
            delegate.downloadService(self, didFailToDownloadWithError: error)
            return
        }
        
        if let error = WorkfinderError(response: httpResponse, attempting: attempting, retryHandler: nil) {
            delegate.downloadService(self, didFailToDownloadWithError: error)
            return
        }
        
        delegate.downloadService(self, didFinishDownloadingToUrl: location)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let fractionComplete = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        delegate.downloadServiceProgressed(self, fractionComplete: fractionComplete)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        delegate.downloadServiceFinishedBackgroundSession(self)
    }
}
