import Foundation
import WorkfinderCommon

public class F4SDocumentUploader : NSObject, F4SDocumentUploaderProtocol {
    
    public var delegate : F4SDocumentUploaderDelegate?
    public static let sessionIdentifier = "F4SDocumentUploaderSession"
    public lazy var boundary: String = { return generateBoundary() }()
    public let document: F4SDocument
    public let documentName: String
    public let documentType: F4SUploadableDocumentType
    public let localUrl: URL
    public let placementUuid: F4SUUID

    var task: F4SNetworkTask?
    let configuration: NetworkConfig
    let targetUrl: URL
    var data: Data!
    
    public internal (set) var state: DocumentUploadState {
        didSet {
            delegate?.documentUploader(self, didChangeState: state)
        }
    }
    
    lazy var sessionConfiguration: URLSessionConfiguration = {
        return self.configuration.sessionManager.interactiveSession.configuration
    }()
    
    lazy var session: URLSession = {
        var session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    public init?(document: F4SDocument, placementUuid: F4SUUID, configuration: NetworkConfig) {
        guard
            let localUrlString = document.localUrlString,
            let localUrl = URL(string: localUrlString),
            let documentName = document.name
            else { return nil }
        let targetUrlString = ""
        guard let targetUrl = URL(string: targetUrlString) else { return nil }
        self.targetUrl = targetUrl
        self.placementUuid = placementUuid
        self.document = document
        self.documentName = documentName
        self.documentType = document.type
        self.localUrl = localUrl
        self.state = .waiting
        self.configuration = configuration
        super.init()
        guard let data = createMultipartData() else { return nil }
        self.data = data
    }
    
    func makeTask() -> F4SNetworkTask {
        var headers = [String:String]()
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers["Content-Length"] = String(data.count)
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = data
        let taskFactory = F4SNetworkTaskFactory(configuration: configuration)
        let task = taskFactory.networkTask(with: request, session: session, attempting: "Upload document") { [weak self] (result) in
            DispatchQueue.main.async {
                guard let this = self else { return }
                switch result {
                case .error(let error):
                    this.state = .failed(error: error)
                    return
                case .success(let data):
                    guard let _ = data else { return }
                    print("Document(s) did upload")
                    this.document.isUploaded = true
                    this.state = .completed
                }
            }
        }
        return task
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    public func resume() {
        switch state {
        case .waiting, .paused(_):
            if task == nil { task = makeTask() }
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
        
        for (key,value) in dictionary {
            bodyData.append("--\(boundary)\r\n")
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            bodyData.append("\(value)\r\n")
        }
        
        bodyData.append("--\(boundary)\r\n")
        bodyData.append("Content-Disposition: form-data; name=\"document\"; filename=\"\(documentName).pdf\"\r\n")
        bodyData.append("Content-Type: application/pdf\r\n\r\n")
        bodyData.append(fileData)
        bodyData.append("\r\n")
        bodyData.append("--\(boundary)--")
        return bodyData
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
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


