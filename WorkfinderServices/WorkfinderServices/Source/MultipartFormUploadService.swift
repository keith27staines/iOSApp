
import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol MutlipartFormUploadServiceDelegate {
    func documentUploader(_ : MutlipartFormUploadService, didChangeState: DocumentUploadState)
}

public class MutlipartFormUploadService : NSObject {
    
    public var delegate : MutlipartFormUploadServiceDelegate?
    public static let sessionIdentifier = "MutlipartFormUploadService"
    public let networkConfig: NetworkConfig
    var task: URLSessionDataTask?
    
    public internal (set) var state: DocumentUploadState {
        didSet {
            delegate?.documentUploader(self, didChangeState: state)
        }
    }
    
    lazy var sessionConfiguration: URLSessionConfiguration = {
        return URLSessionConfiguration.default
    }()
    
    lazy var session: URLSession = {
        var session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    public init(networkConfig: NetworkConfig) {
        self.networkConfig = networkConfig
        self.state = .preparing
        super.init()
    }
    
    func upload(name: String, fields: [String: String], fileBytes: Data, to url: URL) {
        task?.cancel()
        buildTask(name: name, fields: fields, fileBytes: fileBytes, to: url)
        task?.resume()
    }
    
    func buildTask(name: String, fields: [String: String], fileBytes: Data, to url: URL) {
        let form = MultipartForm(name: name, fields: fields, fileBytes: fileBytes)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = form.headers
        request.httpBody = form.data
        task = session.dataTask(with: networkConfig.signedRequest(request))
    }
    
    public func cancel() {
        task?.cancel()
    }
    
}

extension MutlipartFormUploadService : URLSessionTaskDelegate, URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        state = .uploading(fraction: Float(totalBytesSent)/Float(totalBytesExpectedToSend))
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        
        if let error = WorkfinderError(response: httpResponse, retryHandler: nil) {
            state = .failed(error: error)
            return
        }
        state = DocumentUploadState.completed
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

struct MultipartForm {
    
    internal private (set) var data = Data()
    var boundary: String { return "Boundary-\(NSUUID().uuidString)" }
    
    var headers: [String: String] {
        var headers = [String:String]()
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers["Content-Length"] = String(data.count)
        return headers
    }
    
    init(name: String, fields: [String: String], fileBytes: Data) {
        data = createMultipartData(name: name, dictionary: fields, fileData: data)
    }
    
    private func createMultipartData(name: String, dictionary: [String: String], fileData: Data) -> Data {
        var data = Data()
        data = appendFields(dictionary, to: data)
        data = appendDocument(name: name, fileData: fileData, to: data)
        return data
    }
    
    private func appendFields(_ fields: [String: String], to data: Data) -> Data {
        var data = data
        for (key,value) in fields {
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            data.append("\(value)\r\n")
        }
        return data
    }
    
    private func appendDocument(name: String, fileData: Data, to data: Data) -> Data {
        var data = data
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"document\"; filename=\"\(name)\"\r\n")
        data.append("Content-Type: application/pdf\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
        data.append("--\(boundary)--")
        return data
    }
    
}

extension Data{
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

