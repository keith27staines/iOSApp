//
//  F4SDownloadService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public protocol F4SDownloadServiceProtocol {
    func resume()
    func pause()
    func cancel()
}

public protocol F4SDownloadServiceDelegate  {
    func downloadService(_ service: F4SDownloadService, didFinishDownloadingToLocation toUrl: URL)
    func downloadServiceProgressed(_ service: F4SDownloadService, fractionComplete: Double)
}

public class F4SDownloadService : NSObject, F4SDownloadServiceProtocol {
  
    private var downloadTask: URLSessionDownloadTask? = nil
    private var session: URLSession? = nil
    private var resumeData: Data? = nil
    private var delegate: F4SDownloadServiceDelegate
    
    public init(from url: URL, to localUrl: URL, delegate: F4SDownloadServiceDelegate) {
        self.delegate = delegate
        super.init()
        downloadTask = F4SDownloadService.downloadTask(from: url, to: localUrl, delegate: self)
    }
    
    public func pause() {
        downloadTask?.suspend()
    }
    
    public func cancel() {
        downloadTask?.cancel(byProducingResumeData: { [weak self] (data) in
            self?.resumeData = data
        })
    }
    
    public func resume() {
        downloadTask?.resume()
    }
    
    deinit {
        session?.invalidateAndCancel()
    }
}

extension F4SDownloadService {
    
    public static func downloadTask(from url: URL, to localUrl: URL, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask? {
        let configuration = baseConfiguration()
        configuration.allowsCellularAccess = false
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: OperationQueue.main)
        let task = session.downloadTask(with: request)
        return task
    }
    
    public static func baseConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.background(withIdentifier: "background")
        config.httpAdditionalHeaders = F4SDataTaskService.defaultHeaders
        return config
    }
    

}

extension F4SDownloadService : URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else {
            let error = F4SNetworkDataErrorType.noData
            log.error(error)
            return
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let error = F4SNetworkError(response: httpResponse, attempting: "Background download", logError: false)
            log.error(error)
            return
        }
        do {
            try FileManager.default.moveItem(at: location, to: location)
            delegate.downloadService(self, didFinishDownloadingToLocation: location)
        } catch {
            log.error(error)
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let fractionComplete = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        delegate.downloadServiceProgressed(self, fractionComplete: fractionComplete)
    }
    
}
