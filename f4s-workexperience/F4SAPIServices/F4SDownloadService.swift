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

public protocol F4SDownloadServiceDelegate  {
    func downloadService(_ service: F4SDownloadService, didFinishDownloadingToUrl: URL)
    func downloadService(_ service: F4SDownloadService, didFailToDownloadWithError: F4SNetworkError)
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
        configuration.httpAdditionalHeaders = F4SDataTaskService.defaultHeaders
        configuration.allowsCellularAccess = true
        configuration.sessionSendsLaunchEvents = true
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true
        }
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
        defer {
            self.downloadTask = nil
        }
        
        let attempting = "Background download"
        let successCodes = 200...299
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else {
            let error = F4SNetworkDataErrorType.noData.error(attempting: attempting)
            delegate.downloadService(self, didFailToDownloadWithError: error)
            return
        }
        
        guard successCodes.contains(httpResponse.statusCode) else {
            let error = F4SNetworkError(response: httpResponse, attempting: attempting) ?? F4SNetworkDataErrorType.unknownError(nil).error(attempting: attempting)
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
