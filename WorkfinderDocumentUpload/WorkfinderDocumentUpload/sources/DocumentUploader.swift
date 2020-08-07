
class DocumentUploader {
    
    private var cancelled: Bool = false
    
    func cancel() {
        cancelled = true
    }

    func uploadDocument(to url: String, progress: @escaping (Result<Float,Error>) -> Void, completion: @escaping (Error?)->Void ) {
        cancelled = false
        let interval: TimeInterval = 3.0 / 100.0
        DispatchQueue.global(qos: .background).async {
            for percentage in 0...100 {
                DispatchQueue.main.asyncAfter(deadline: .now()+interval) { [weak self] in
                    guard let self = self else { return }
                    if !self.cancelled {
                        progress(Result<Float,Error>.success(Float(percentage)/100.0))
                    }
                }
            }
        }
    }
}
