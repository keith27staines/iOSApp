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

