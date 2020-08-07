
class DocumentUploader {
    func uploadDocument(to url: String, progress: @escaping (Result<Float,Error>) -> Void, completion: @escaping (Error?)->Void ) {
        let interval: TimeInterval = 3.0 / 100.0
        DispatchQueue.global(qos: .background).async {
            for percentage in 0...100 {
                DispatchQueue.main.asyncAfter(deadline: .now()+interval){
                    progress(Result<Float,Error>.success(Float(percentage)/100.0))
                }
            }
        }
    }
}
