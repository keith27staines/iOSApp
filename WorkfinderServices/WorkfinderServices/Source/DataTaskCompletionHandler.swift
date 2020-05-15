
import Foundation
import WorkfinderCommon

public class DataTaskCompletionHandler {
    
    let logger: NetworkCallLoggerProtocol
    
    public init(logger: NetworkCallLoggerProtocol) {
        self.logger = logger
    }
    
    public func convertToDataResult(attempting: String,
                                    request: URLRequest,
                                    responseData: Data?,
                                    httpResponse: HTTPURLResponse?,
                                    error: Error?,
                                    completion: @escaping((Result<Data,Error>) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let response = httpResponse, let data = responseData else {
                var workfinderError: WorkfinderError?
                if responseData == nil {
                    workfinderError = WorkfinderError(errorType: .noData, attempting: attempting, retryHandler: nil)
                }
                if let error = error {
                    workfinderError = WorkfinderError.init(from: error as NSError, retryHandler: nil)
                }
                if httpResponse == nil {
                    workfinderError = WorkfinderError(
                        title: "Consistency error",
                        description: "A data task returned an inconsistent response")
                }
                guard let nonNilError = workfinderError else {
                    assertionFailure("Error should not be nil now")
                    return
                }
                self?.logger.logDataTaskFailure(error: nonNilError)
                let result = Result<Data,Error>.failure(nonNilError)
                completion(result)
                return
            }
            
            if let httpError = WorkfinderError(request: request, response: response, data: data, retryHandler: nil) {
                self?.logger.logDataTaskFailure(error: httpError)
                let result = Result<Data,Error>.failure(httpError)
                completion(result)
                return
            }
            
            let workfinderError = WorkfinderError(errorType: .noData, attempting: attempting, retryHandler: nil)
            let result = Result<Data, Error>.failure(workfinderError)
            self?.logger.logDataTaskFailure(error: workfinderError)
            completion(result)
        }
    }
}
