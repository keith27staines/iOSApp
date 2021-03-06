
import WorkfinderCommon
import WorkfinderServices

public protocol DocumentUploaderProtocol {
    func upload(
        progress: @escaping (Result<Float,Error>) -> Void,
        completion: @escaping (Error?)->Void )
    func cancel()
}

public class DocumentUploader: DocumentUploaderProtocol {
    
    private var cancelled: Bool = false
    let filename: String
    let mime: String
    let filedata: Data
    let metadata: [String:String]
    let url: URL
    let method: RequestVerb
    
    let service: DocumentUploadServiceProtocol?
    var progress: ((Result<Float,Error>) -> Void)?
    var completion: ((Error?) -> Void)?
    var error: Error?
    
    var timerCompleted: Bool = false {
        didSet {
            checkFinished()
        }
    }
    
    var timerFraction: Float = 0 {
        didSet {
            updateProgress()
        }
    }
    
    var bytesFraction: Float = 0 {
        didSet {
            updateProgress()
        }
    }
    
    var uploadCompleted: Bool = false  {
        didSet {
            checkFinished()
        }
    }
    
    func updateProgress() {
        let fraction = min(bytesFraction, timerFraction)
        progress?(Result<Float, Error>.success(fraction))
    }
    
    func checkFinished() {
        guard !cancelled && error == nil && timerCompleted && uploadCompleted else { return }
        completion?(nil)
    }
    
    public init(service: DocumentUploadServiceProtocol,
                filename: String,
                mime: String,
                filedata: Data,
                metadata: [String:String],
                to url: URL,
                method: RequestVerb) {
        self.service = service
        self.filename = filename
        self.mime = mime
        self.filedata = filedata
        self.metadata = metadata
        self.url = url
        self.method = method
    }
    
    public func cancel() {
        cancelled = true
    }
    
    func prepareForUpload() {
        cancelled = false
        bytesFraction = 0
        timerCompleted = false
        uploadCompleted = false
        service?.delegate = self
        error = nil
    }
    
    public func upload(
        progress: @escaping (Result<Float,Error>) -> Void,
        completion: @escaping (Error?)->Void
    ) {
        self.progress = progress
        self.completion = completion
        prepareForUpload()
        let now = DispatchTime.now()
        service?.beginUpload(
            name: filename,
            mime: mime,
            fields: metadata,
            fileBytes: filedata,
            to: url,
            method: method
        )
        DispatchQueue.global(qos: .background).async {
            for percentage in 0...100 {
                guard !self.cancelled else { break }
                let deadline = now + Double(3*percentage)/100.0
                DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
                    guard let self = self else { return }
                    if !self.cancelled {
                        self.timerFraction = Float(percentage)/100.0
                        self.timerCompleted = percentage == 100
                    }
                }
            }
        }
    }
}

extension DocumentUploader: DocumentUploadServiceDelegate {
    public func documentUploader(_ service: DocumentUploadService, didChangeState state: DocumentUploadState) {
        switch state {
        case .preparing:
            bytesFraction = 0
        case .uploading(fraction: let fraction):
            bytesFraction = fraction
        case .completed:
            uploadCompleted = true
        case .cancelled:
            bytesFraction = 0
        case .failed(error: let error):
            completion?(error)
        }
    }
}
