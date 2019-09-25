import Foundation
import WorkfinderCommon
import WorkfinderServices

class MockDataTask : F4SNetworkTask {
    var cancelWasCalled: Bool = false
    var resumeWasCalled: Bool = false
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var expectedData: Data?
    var expectedResponse: URLResponse?
    var expectedError: Error?
    var request: URLRequest?
    
    func cancel() {
        cancelWasCalled = true
    }
    
    func resume() {
        resumeWasCalled = true
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            self?.completion?(this.expectedData,
                              this.expectedResponse,
                              this.expectedError)
        }
    }
}

class MockLogger: NetworkCallLoggerProtocol {
    var attempting: String?
    var logDataTaskFailureWasCalled: Bool = false
    var logDataTaskSuccessWasCalled: Bool = false
    var request: URLRequest?
    var response: URLResponse?
    var responseData: Data?
    var error: Error?
    
    func logDataTaskFailure(attempting: String?, error: Error, request: URLRequest, response: HTTPURLResponse?, responseData: Data?) {
        logDataTaskFailureWasCalled = true
        self.attempting = attempting
        self.error = error
        self.request = request
        self.response = response
        self.responseData = responseData
    }
    
    func logDataTaskSuccess(request: URLRequest, response: HTTPURLResponse, responseData: Data) {
        logDataTaskSuccessWasCalled = true
        self.request = request
        self.response = response
        self.responseData = responseData
    }
}
