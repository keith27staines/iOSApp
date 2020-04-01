
import Foundation

public class TaskCompletionHandler {
    
    func handleResult(data: Data?, response: URLResponse?, error: Error?, completion: @escaping((Result<Data,Error>) -> Void)) {
        DispatchQueue.main.async {
            guard let response = response as? HTTPURLResponse else {
                if let error = error {
                    let result = Result<Data, Error>.failure(error)
                    completion(result)
                    return
                }
                return
            }
            let code = response.statusCode
            switch code {
            case 200..<300:
                guard let  data = data else {
                    let httpError = NetworkError.responseBodyEmpty(response)
                    let result = Result<Data, Error>.failure(httpError)
                    completion(result)
                    return
                }
                completion(Result<Data,Error>.success(data))
            default:
                let httpError = NetworkError.httpError(response)
                let result = Result<Data, Error>.failure(httpError)
                completion(result)
                return
            }
        }
    }
}