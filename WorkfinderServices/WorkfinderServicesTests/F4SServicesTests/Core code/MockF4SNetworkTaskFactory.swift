import XCTest
import WorkfinderCommon
import WorkfinderServices

class MockF4SNetworkTaskFactory<A:Codable> : F4SNetworkTaskFactoryProtocol {
    
    let factory: F4SNetworkTaskFactory
    let requiredSuccessResult: F4SNetworkResult<A>?
    let requiredNetworkError: F4SNetworkError?
    
    init(requiredSuccessResult: F4SNetworkResult<A>) {
        self.factory = F4SNetworkTaskFactory(configuration: makeTestConfiguration())
        self.requiredSuccessResult = requiredSuccessResult
        self.requiredNetworkError = nil
    }
    init(requiredNetworkError: F4SNetworkError) {
        self.factory = F4SNetworkTaskFactory(configuration: makeTestConfiguration())
        self.requiredNetworkError = requiredNetworkError
        self.requiredSuccessResult = nil
    }
    
    func urlRequest(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?) -> URLRequest {
        return factory.urlRequest(verb: verb, url: url, dataToSend: dataToSend)
    }
    
    func networkTask(verb: F4SHttpRequestVerb, url: URL, dataToSend: Data?, attempting: String, session: F4SNetworkSession, completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        let task = MockNetworkTask<A>(verb: verb, attempting: attempting, session: session, completion: completion)
        task.url = url
        guard let requiredSuccessResult = requiredSuccessResult else {
            task.requiredDataResult = F4SNetworkDataResult.error(requiredNetworkError!)
            return task
        }
        if case F4SNetworkResult.success(let json) = requiredSuccessResult {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
            let data = try! encoder.encode(json)
            let requiredDataResult = F4SNetworkDataResult.success(data)
            task.requiredDataResult = requiredDataResult
            return task
        }
        XCTFail("This MockF4SNetworkTaskFactory has not been configured to either return a success result or an error result")
        return task
        
    }
    
    func networkTask(with request: URLRequest, session: F4SNetworkSession, attempting: String, completion: @escaping (F4SNetworkDataResult) -> ()) -> F4SNetworkTask {
        return MockNetworkTask<A>(verb: F4SHttpRequestVerb.get, attempting: attempting, session: session, completion: completion)
    }
}

class MockNetworkTask<A:Decodable> : F4SNetworkTask {
    var cancelWasCalled: Bool = false
    var resumeWasCalled: Bool = false
    var verb: F4SHttpRequestVerb?
    var attempting: String?
    var completion: ((F4SNetworkDataResult) -> ())?
    var session: F4SNetworkSession
    var requiredDataResult: F4SNetworkDataResult!
    var url: URL?
    
    init(verb: F4SHttpRequestVerb,
         attempting: String,
         session: F4SNetworkSession,
         completion: @escaping (F4SNetworkDataResult) -> ()) {
        self.verb = verb
        self.attempting = attempting
        self.session = session
        self.completion = completion
    }
    
    func cancel() {
        cancelWasCalled = true
    }
    
    func resume() {
        resumeWasCalled = true
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.completion?(strongSelf.requiredDataResult)
        }
    }
}

extension String : Error {}

public class MockF4SNetworkSessionManager: F4SNetworkSessionManagerProtocol {
    
    public var interactiveSession: URLSession {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }
    
    
}
