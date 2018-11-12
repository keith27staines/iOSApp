//
//  MultipartUpload.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 11/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SDocumentUploaderDelegate : class {
    func documentUploader(_ uploader: F4SDocumentUploader, didChangeState state: F4SDocumentUploader.State)
}

public class F4SDocumentUploader : NSObject {
    
    public var delegate : F4SDocumentUploaderDelegate?
    public static let sessionIdentifier = "F4SDocumentUploaderSession"
    
    public static let sessionConfiguration: URLSessionConfiguration = {
        var config = URLSessionConfiguration.default
        return config
    }()

    public enum State {
        case waiting
        case uploading(fraction: Float)
        case completed
        case cancelled
        case paused(fraction: Float)
        case failed(error: Error)
    }
    
    public private (set) var state: State {
        didSet {
            delegate?.documentUploader(self, didChangeState: state)
        }
    }
    
    public lazy var session: URLSession = {
        var session = URLSession(configuration: F4SDocumentUploader.sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    public let standardHeaders = F4SDataTaskService.defaultHeaders
    public lazy var boundary: String = { return generateBoundary() }()
    public let document: F4SDocument
    public let documentName: String
    public let documentType: F4SUploadableDocumentType
    public let localUrl: URL
    private var task: URLSessionDataTask?
    
    public var targetUrl: URL {
        let urlString = ApiConstants.postDocumentsUrl
        let url = URL(string: urlString)
        return url!
    }
    
    public lazy var request: URLRequest = {
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        return request
    }()
    
    public init?(document: F4SDocument) {
        guard
            let localUrlString = document.localUrlString,
            let localUrl = URL(string: localUrlString),
            let documentName = document.name
            else { return nil }
        self.document = document
        self.documentName = documentName
        self.documentType = document.type
        self.localUrl = localUrl
        self.state = .waiting
        super.init()
        request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        guard let data = createMultipartData() else { return nil }
        task = session.uploadTask(with: request, from: data)
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func resume() {
        switch state {
        case .waiting, .paused(_):
            task?.resume()
        default: return
        }
    }
    
    func createMultipartData() -> Data? {

        var bodyData = Data()
        let fileData: Data
        do {
            fileData = try Data(contentsOf: localUrl)
        } catch let error {
            state = .failed(error: error)
            return nil
        }
        
        var dictionary = [String: String]()
        dictionary["doc_type"] = documentType.rawValue
        dictionary["title"] = documentName
        dictionary["document"] = documentName + ".pdf"
        
        for (key,value) in dictionary {
            bodyData.append("\(boundary)\r\n")
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            bodyData.append("\(value)\r\n")
        }
        
        bodyData.append("\(boundary)\r\n")
        bodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(documentName).pdf\"\r\n")
        bodyData.append("Content-Type: application/pdf\r\n\r\n")
        bodyData.append(fileData)
        bodyData.append("\r\n")
        bodyData.append("\(boundary)--")
        return bodyData
    }
    
    func generateBoundary() -> String {
        return "----Boundary-\(NSUUID().uuidString)"
    }
}
extension F4SDocumentUploader : URLSessionTaskDelegate, URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("total bytes sent \(totalBytesSent)")
        let percentComplete = Int(Float(totalBytesSent)/Float(totalBytesExpectedToSend)*100.0)
        print("fraction complete = \(percentComplete)")
        state = .uploading(fraction: Float(totalBytesSent)/Float(totalBytesExpectedToSend))
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        if let error = F4SNetworkError(response: httpResponse, attempting: "upload document") {
            state = .failed(error: error)
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            state = .failed(error: error)
        }
    }
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }

}

extension Data{
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}


