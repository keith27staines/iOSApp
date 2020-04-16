import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class F4SDataTaskServiceTests: XCTestCase {

    func test_initialise() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        
        XCTAssertEqual(sut.apiName, "apiName")
        XCTAssertEqual(sut.baseUrl, URL(string: "baseUrl"))
        XCTAssertEqual(sut.url, URL(string: "baseUrl/apiName"))
    }
    
    func test_add_relativeUrl() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        sut.relativeUrlString = "relativeUrl"
        XCTAssertEqual(sut.url, URL(string: "baseUrl/apiName/relativeUrl"))
    }
    
    func test_cancel() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let mockTask = MockTask()
        sut.task = mockTask
        mockTask.cancelled = false
        sut.cancel()
        XCTAssertTrue(mockTask.cancelled)
    }
    
    func test_request_header_fields_without_user_uuid() {
        let url = URL(string: "/v2")!
        let request = URLRequest(url: url)
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let task = sut.networkTask(with: request, attempting: "test") { (dataResult) in }
        let headers = (task as? URLSessionDataTask)!.originalRequest!.allHTTPHeaderFields
        XCTAssertNil(headers)
    }
    
    //MARK:- get request tests
    
    func test_begin_get_request_cancels_previous_task() {
        let sut = F4SDataTaskService(baseURLString: "baseUrl", apiName: "apiName", configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        let newTask = MockTask()
        sut.session = MockSession(task: newTask)
        sut.beginGetRequest(attempting: "get json") { (result : F4SNetworkResult<[String]>) in }
        XCTAssertTrue(previousTask.cancelled)
    }
    
    func test_begin_get_request_calls_resume_on_new_task() {
        let sut = F4SDataTaskService(baseURLString: "baseUrl", apiName: "apiName", configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        let newTask = MockTask()
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginGetRequest")
        sut.beginGetRequest(attempting: "get json") { (result : F4SNetworkResult<[String]>) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_begin_get_request_generating_error() {
        let sut = makeSUT()
        let newTask = MockTask()
        newTask.dataTaskResult = (nil, nil, "test error")
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginGetRequest")
        sut.beginGetRequest(attempting: "get something") { (result : F4SNetworkResult<[String]>) in
            switch result {
            case .error(let error):
                XCTAssertEqual(error.attempting, "get something")
            case .success(_):
                XCTFail("The get should return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_begin_get_request_generating_success_response() {
        let sut = makeSUT()
        let jsonObject = ["jsonObject"]
        let newTask = mockTaskWithResponse(code: 200, responseBody: jsonObject)
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginGetRequest")
        sut.beginGetRequest(attempting: "get something") { (result : F4SNetworkResult<[String]>) in
            switch result {
            case .error(_):
                XCTFail("The get should return a success result")
                
            case .success(let stringArray):
                XCTAssertEqual(stringArray[0], "jsonObject")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_begin_get_request_generating_failure_response() {
        let sut = makeSUT()
        let jsonObject = ["Error"]
        let newTask = mockTaskWithResponse(code: 400, responseBody: jsonObject)
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginGetRequest")
        sut.beginGetRequest(attempting: "get something") { (result : F4SNetworkResult<[String]>) in
            switch result {
            case .error(let error):
                XCTAssertTrue(error.code == "400")
            case .success(_):
                XCTFail("The get should return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_begin_get_request_generating_deserialization_error() {
        let badData = Data()
        let newTask = mockTaskWithResponse(code: 200, responseBodyData: badData)
        let sut = makeSUT()
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginGetRequest")
        sut.beginGetRequest(attempting: "get something") { (result : F4SNetworkResult<[String]>) in
            switch result {
            case .error(let error):
               XCTAssertEqual(error.code, F4SNetworkDataErrorType.deserialization(badData).error(attempting: "").code)
            case .success(_):
                XCTFail("This test is designed to produce an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    //MARK:- send request tests
    
    func test_begin_send_request_cancels_previous_task() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        let newTask = MockTask()
        sut.session = MockSession(task: newTask)
        let object = ["send this"]
        sut.beginSendRequest(verb: RequestVerb.patch, objectToSend: object, attempting: "send json") { (result : F4SNetworkDataResult) in }
        XCTAssertTrue(previousTask.cancelled)
    }
    
    func test_begin_send_request_calls_resume_on_new_task() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        let newTask = MockTask()
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginSendRequest")
        let object = ["send this"]
        sut.beginSendRequest(verb: RequestVerb.patch, objectToSend: object, attempting: "send json") { (result : F4SNetworkDataResult) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_begin_send_request_generating_error() {
        let sut = makeSUT()
        let newTask = MockTask()
        newTask.dataTaskResult = (nil, nil, "test error")
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginSendRequest")
        let object = ["send this"]
        sut.beginSendRequest(verb: RequestVerb.patch, objectToSend: object, attempting: "send json") {
            (result : F4SNetworkDataResult) in
            switch result {
            case .error(let error):
                XCTAssertEqual(error.attempting, "send json")
            case .success(_):
                XCTFail("The test was designed to return an error result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_begin_send_request_generating_success() {
        let sut = makeSUT()
        let jsonObject = ["jsonObject"]
        let newTask = mockTaskWithResponse(code: 200, responseBody: jsonObject)
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginGetRequest")
        let object = ["send this"]
        sut.beginSendRequest(verb: RequestVerb.patch, objectToSend: object, attempting: "send json") {
            (result : F4SNetworkDataResult) in
            switch result {
            case .error(_):
                XCTFail("The get should return a success result")
                
            case .success(let responseData):
                let jsonObject = try! sut.jsonDecoder.decode([String].self, from: responseData!)
                XCTAssertEqual(jsonObject[0], "jsonObject")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_beginDelete_calls_cancel_on_previous_task() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        let newTask = MockTask()
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginDeleteRequest")
        sut.beginDelete(attempting: "") { (result : F4SNetworkDataResult) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(previousTask.cancelled)
    }
    
    func test_beginDelete_calls_resume_on_new_task() {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        let newTask = MockTask()
        sut.session = MockSession(task: newTask)
        let expectation = XCTestExpectation(description: "beginDeleteRequest")
        sut.beginDelete(attempting: "") { (result : F4SNetworkDataResult) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(newTask.resumeWasCalled)
    }
    
    func test_URLSessionConformsToF4SNetworkSession() {
        let url = URL(string: "/something")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: url)
        let networkTask = session.networkTask(with: request) { (data, response, error) in }
        XCTAssertNotNil(networkTask as? URLSessionDataTask)
    }
}

//MARK:- helpers
extension F4SDataTaskServiceTests {

    func mockTaskWithResponse(code: Int, responseBodyData: Data?) -> MockTask {
        let newTask = MockTask()
        let url = URL(string: "https://someurl.somewhere.com")!
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: "HTTP/1.1", headerFields: nil)
        newTask.dataTaskResult = (responseBodyData, response, nil)
        return newTask
    }
    
    func mockTaskWithResponse<EncodableType: Encodable>(code: Int, responseBody: EncodableType?) -> MockTask {
        let data: Data? = try? JSONEncoder().encode(responseBody)
        return mockTaskWithResponse(code: code, responseBodyData: data)
    }
    
    func makeSUT() -> F4SDataTaskService {
        let sut = F4SDataTaskService(
            baseURLString: "baseUrl",
            apiName: "apiName",
            configuration: makeTestConfiguration())
        let previousTask = MockTask()
        sut.task = previousTask
        return sut
    }
}

class MockSession : F4SNetworkSession {
    
    init(task: MockTask) {
        self.mockTask = task
    }
    
    var mockTask: MockTask
    func networkTask(with: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> F4SNetworkTask {
        mockTask.completion = completionHandler
        return mockTask
    }
    
    var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    
}

class MockTask : F4SNetworkTask {
    var cancelled: Bool = false
    var resumeWasCalled: Bool = false
    var completion: ((Data?, URLResponse?,Error?) -> Void)?
    var dataTaskResult: (Data?, URLResponse?,Error?) = (nil,nil,"Test Error")
    
    func cancel() {
        cancelled = true
    }
    
    func resume() {
        self.resumeWasCalled = true
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let result = strongSelf.dataTaskResult
            strongSelf.completion?(result.0,result.1,result.2)
        }
    }
    
    init(completion: ((Data?, URLResponse?,Error?) -> Void)? = nil) {
        self.completion = completion
    }
}
