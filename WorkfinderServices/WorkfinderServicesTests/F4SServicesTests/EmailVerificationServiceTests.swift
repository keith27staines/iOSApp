//
//  EmailVerificationServiceTests.swift
//  WorkfinderServicesTests
//
//  Created by Keith Dev on 23/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
import WorkfinderNetworking
@testable import WorkfinderServices

class EmailVerificationServiceTests: XCTestCase {
    let email = "email"
    let clientId = "clientId"
    func test_initialise() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.startClientId, clientId)
    }
    
    func test_cancel() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let mockTask = MockTask(completion: { (data, response, error) in })
        sut.task = mockTask
        sut.cancel()
        XCTAssertTrue(mockTask.cancelled)
    }
    
    
    func test_prepareRequest() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let data = Data()
        let request = sut.prepareRequest(urlString: "url/url", method: "POST", bodyData: data)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, URL(string: "url/url")!)
    }
    
    func test_codeValidationError() {
        XCTAssertNil(validationErrorFromCode(200))
        XCTAssertTrue(validationErrorFromCode(401)!.localizedDescription == EmailVerificationService.CodeValidationError.codeEmailCombinationNotValid.localizedDescription)
        XCTAssertTrue(validationErrorFromCode(456)!.localizedDescription == EmailVerificationService.CodeValidationError.networkError(456).localizedDescription)
    }
    
    func validationErrorFromCode(_ code: Int) -> EmailVerificationService.CodeValidationError? {
        return EmailVerificationService.CodeValidationError.codeValidationError(from: code)
    }
    
    func test_submissionError() {
        XCTAssertNil(submissionErrorFromCode(200))
        XCTAssertEqual(submissionErrorFromCode(400)?.localizedDescription,  EmailVerificationService.EmailSubmissionError.serversideEmailFormatCheckFailed.localizedDescription)
        XCTAssertEqual(submissionErrorFromCode(445)?.localizedDescription,  EmailVerificationService.EmailSubmissionError.networkError(456).localizedDescription)
    }
    
    
    func test_base64EncodedTelemeteryValue() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let string = sut.base64EncodedTelemeteryValue()
        let data =  Data(base64Encoded: string)!
        let telemetery = try! JSONDecoder().decode(Telemetery.self, from: data)
        XCTAssertEqual(telemetery.name, Telemetery().name)
    }
    
    func test_logResult_with_error() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let url = URL(string: "abc")!
        let request = URLRequest(url: url)
        let error = F4SError.genericError("generic error")
        let mockLogger = MockLogger()
        sut.logResult(attempting: "attempting", request: request, data: nil, response: nil, error: error, logger: mockLogger)
        XCTAssertTrue(mockLogger.logDataTaskFailureWasCalled)
        XCTAssertFalse(mockLogger.logDataTaskSuccessWasCalled)
        XCTAssertNotNil(mockLogger.request)
        XCTAssertNotNil(mockLogger.error)
    }
    
    func test_logResult_with_nil_data() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let url = URL(string: "abc")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 789, httpVersion: "http", headerFields: nil)
        let mockLogger = MockLogger()
        sut.logResult(attempting: "attempting", request: request, data: nil, response: response, error: nil, logger: mockLogger)
        XCTAssertTrue(mockLogger.logDataTaskFailureWasCalled)
        XCTAssertFalse(mockLogger.logDataTaskSuccessWasCalled)
        XCTAssertNotNil(mockLogger.request)
        XCTAssertNotNil(mockLogger.response)
    }
    
    func test_logResult_with_response() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let url = URL(string: "abc")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 789, httpVersion: "http", headerFields: nil)
        let data = Data()
        let mockLogger = MockLogger()
        sut.logResult(attempting: "attempting", request: request, data: data, response: response, error: nil, logger: mockLogger)
        XCTAssertFalse(mockLogger.logDataTaskFailureWasCalled)
        XCTAssertTrue(mockLogger.logDataTaskSuccessWasCalled)
        XCTAssertNotNil(mockLogger.request)
        XCTAssertNotNil(mockLogger.response)
        XCTAssertNotNil(mockLogger.responseData)
    }
    
    func test_start_resulting_in_error() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let task = MockDataTask()
            task.request = request
            task.completion = completion
            task.expectedError = F4SError.genericError("test error")
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.start(
            onSuccess: { (string) in
            XCTFail("This task was designed to have a fail result")
        }, onFailure: { (string, error) in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func test_start_resulting_in_error_response() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let url = URL(string: "url")!
            let task = MockDataTask()
            task.request = request
            task.expectedData = Data()
            task.completion = completion
            task.expectedResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "http", headerFields: nil)
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.start(
            onSuccess: { (string) in
                XCTFail("This task was designed to have a fail result")
        }, onFailure: { (string, error) in
            switch error {
            case .networkError(_): break // expected result
            default: XCTFail("The call failed with the wrong error")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func test_start_resulting_in_decline() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let url = URL(string: "url")!
            let task = MockDataTask()
            task.request = request
            task.expectedData = Data()
            task.completion = completion
            task.expectedResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "http", headerFields: nil)
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.start(
            onSuccess: { (string) in
                XCTFail("This task was designed to have a fail result")
        }, onFailure: { (string, error) in
            switch error {
            case .serversideEmailFormatCheckFailed: break // expected result
            default: XCTFail("The call failed with the wrong error")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func test_start_resulting_in_authorized() {
        let sut = EmailVerificationService(email: email, clientId: clientId)
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let url = URL(string: "url")!
            let task = MockDataTask()
            task.request = request
            task.expectedData = Data()
            task.completion = completion
            task.expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "http", headerFields: nil)
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.start(
            onSuccess: { (string) in
                expectation.fulfill()
        }, onFailure: { (string, error) in
            XCTFail("This task was designed to have a success result")
        })
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK:- helpers
    func submissionErrorFromCode(_ code: Int) -> EmailVerificationService.EmailSubmissionError? {
        return EmailVerificationService.EmailSubmissionError.emailSubmissionError(from: code)
    }
    
    func test_verifyWithCode() {
        
    }
}

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

class MockLogger: NetworkCallLogger {
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
