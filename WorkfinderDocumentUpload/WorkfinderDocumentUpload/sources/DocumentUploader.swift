
public protocol DocumentUploaderProtocol {
    func upload(
        to url: String,
        progress: @escaping (Result<Float,Error>) -> Void,
        completion: @escaping (Error?)->Void )
    func cancel()
}

public class DocumentUploader: DocumentUploaderProtocol {
    
    private var cancelled: Bool = false
    
    public init() {}
    
    public func cancel() {
        cancelled = true
    }

    public func upload(
        to url: String,
        progress: @escaping (Result<Float,Error>) -> Void,
        completion: @escaping (Error?)->Void ) {
        cancelled = false
        let now = DispatchTime.now()
        DispatchQueue.global(qos: .background).async {
            for percentage in 0...100 {
                let deadline = now + Double(3*percentage)/100.0
                DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
                    guard let self = self else { return }
                    if !self.cancelled {
                        progress(Result<Float,Error>.success(Float(percentage)/100.0))
                        if percentage == 100 {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
