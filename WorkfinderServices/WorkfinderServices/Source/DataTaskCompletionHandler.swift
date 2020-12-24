
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
        if let error = error as NSError?, error.code == -999 {
            return // request was cancelled
        }
        DispatchQueue.main.async { [weak self] in
            guard let response = httpResponse, let data = responseData else {
                var workfinderError: WorkfinderError?
                if let error = error {
                    workfinderError = WorkfinderError.init(from: error as NSError, attempting: attempting, retryHandler: nil)
                } else if responseData == nil {
                    workfinderError = WorkfinderError(errorType: .noData, attempting: attempting, retryHandler: nil)
                } else if httpResponse == nil {
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
            
            let result = Result<Data,Error>.success(data)
            self?.logger.logDataTaskSuccess(request: request, response: response, responseData: data, verbose: verbose)
            completion(result)
        }
    }
}
