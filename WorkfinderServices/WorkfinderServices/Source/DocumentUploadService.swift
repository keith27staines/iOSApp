
import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol DocumentUploadServiceDelegate {
    func documentUploader(_ service: DocumentUploadService, didChangeState state: DocumentUploadState)
}

public protocol DocumentUploadServiceProtocol: AnyObject {
    var delegate: DocumentUploadServiceDelegate? { get set }
    var state: DocumentUploadState { get }
    func beginUpload(name: String, mime: String, fields: [String: String], fileBytes: Data, to url: URL, method: RequestVerb)
    func cancel()
}

public class DocumentUploadService : NSObject, DocumentUploadServiceProtocol {
    
    public var delegate : DocumentUploadServiceDelegate?
    let networkConfig: NetworkConfig
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
    
    public func beginUpload(
        name: String,
        mime: String,
        fields: [String: String],
        fileBytes: Data,
        to url: URL,
        method:RequestVerb) {
        task?.cancel()
        buildTask(name: name, mime: mime, fields: fields, fileBytes: fileBytes, to: url, method: method)
        task?.resume()
    }
    
    func buildTask(name: String, mime: String, fields: [String: String], fileBytes: Data, to url: URL, method: RequestVerb) {
        let form = DocumentForm(name: name, fields: fields, fileBytes: fileBytes, mime: mime)
        var request = URLRequest(url: url)
        request.httpMethod = method.name
        request.allHTTPHeaderFields = form.headers
        request.httpBody = form.data
        let signedRequest = networkConfig.signedRequest(request)
        task = session.dataTask(with: signedRequest)
    }
    
    public func cancel() {
        task?.cancel()
    }
    
}

extension DocumentUploadService : URLSessionTaskDelegate, URLSessionDataDelegate {
    
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
}

struct DocumentForm {
    
    internal private (set) var data = Data()
    let boundary: String = "Boundary-\(NSUUID().uuidString)"
    let mime: String
    var headers: [String: String] {
        var headers = [String:String]()
        //headers["Content-Length"] = String(data.count)
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        return headers
    }
    
    init(name: String,
         fields: [String: String],
         fileBytes: Data,
         mime: String
    ) {
        self.mime = mime
        data = createMultipartData(name: name, dictionary: fields, fileData: fileBytes)
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
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(name)\"\r\n")
        data.append("Content-Type: \(mime)\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
        data.append("--\(boundary)--\r\n")
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

