//
//  EmailVerificationServiceTests.swift
//  WorkfinderServicesTests
//
//  Created by Keith Dev on 23/08/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderServices

class EmailVerificationServiceTests: XCTestCase {
    let email = "email"
    let clientId = "clientId"
    
    func makeSUT() -> EmailVerificationService {
        let sut = EmailVerificationService(
            email: email,
            clientId: clientId,
            configuration: makeTestConfiguration())
        return sut
    }
    
    func test_initialise() {
        let sut = makeSUT()
        XCTAssertEqual(sut.email, email)
        XCTAssertEqual(sut.startClientId, clientId)
    }
    
    func test_cancel() {
        let sut = makeSUT()
        let mockTask = MockTask(completion: { (data, response, error) in })
        sut.task = mockTask
        sut.cancel()
        XCTAssertTrue(mockTask.cancelled)
    }
    
    
    func test_prepareRequest() {
        let sut = makeSUT()
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
        let sut = EmailVerificationService(
            email: email,
            clientId: clientId,
            configuration: makeTestConfiguration())
        let string = sut.base64EncodedTelemeteryValue()
        let data =  Data(base64Encoded: string)!
        let telemetery = try! JSONDecoder().decode(Telemetery.self, from: data)
        XCTAssertEqual(telemetery.name, Telemetery().name)
    }
    
    func test_logResult_with_error() {
        let sut = EmailVerificationService(
            email: email,
            clientId: clientId,
            configuration: makeTestConfiguration())
        let mockLogger = sut.configuration.logger as! MockLogger
        let url = URL(string: "abc")!
        let request = URLRequest(url: url)
        let error = F4SError.genericError("generic error")
        sut.logResult(attempting: "attempting", request: request, data: nil, response: nil, error: error)
        XCTAssertTrue(mockLogger.logDataTaskFailureWasCalled)
        XCTAssertFalse(mockLogger.logDataTaskSuccessWasCalled)
        XCTAssertNotNil(mockLogger.request)
        XCTAssertNotNil(mockLogger.error)
    }
    
    func test_logResult_with_nil_data() {
        let sut = makeSUT()
        let url = URL(string: "abc")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 789, httpVersion: "http", headerFields: nil)
        let mockLogger = sut.configuration.logger as! MockLogger
        sut.logResult(attempting: "attempting", request: request, data: nil, response: response, error: nil)
        XCTAssertTrue(mockLogger.logDataTaskFailureWasCalled)
        XCTAssertFalse(mockLogger.logDataTaskSuccessWasCalled)
        XCTAssertNotNil(mockLogger.request)
        XCTAssertNotNil(mockLogger.response)
    }
    
    func test_logResult_with_response() {
        let sut = makeSUT()
        let url = URL(string: "abc")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 789, httpVersion: "http", headerFields: nil)
        let data = Data()
        let mockLogger = sut.configuration.logger as! MockLogger
        sut.logResult(attempting: "attempting", request: request, data: data, response: response, error: nil)
        XCTAssertFalse(mockLogger.logDataTaskFailureWasCalled)
        XCTAssertTrue(mockLogger.logDataTaskSuccessWasCalled)
        XCTAssertNotNil(mockLogger.request)
        XCTAssertNotNil(mockLogger.response)
        XCTAssertNotNil(mockLogger.responseData)
    }
    
    func test_start_resulting_in_error() {
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let task = MockDataTask()
        let sut = makeSUT()
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let url = request.url!
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
        XCTAssertEqual(task.request!.httpMethod, "POST")
        XCTAssertEqual(task.request?.url?.absoluteString, "https://founders4schools.eu.auth0.com/passwordless/start")
    }
    
    func test_verifyWithCode_code_and_email_correct() {
        let task = MockDataTask()
        let sut = makeSUT()
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let url = request.url!
            task.request = request
            task.expectedData = Data()
            task.completion = completion
            task.expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "http", headerFields: nil)
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.verifyWithCode(email: "email", code: "1234", onSuccess: { (string) in
            expectation.fulfill()
        }) { (string, error) in
            XCTFail("This test was designed to return a success result")
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(task.request!.httpMethod, "POST")
        XCTAssertEqual(task.request?.url?.absoluteString, "https://founders4schools.eu.auth0.com/oauth/ro")
    }
    
    func test_verifyWithCode_email_incorrect() {
        let task = MockDataTask()
        let sut = makeSUT()
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            let url = request.url!
            task.request = request
            task.expectedData = Data()
            task.completion = completion
            task.expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "http", headerFields: nil)
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.verifyWithCode(email: "wrong email", code: "1234", onSuccess: { (string) in
            XCTFail("This test was designed to return an error result")
        }) { (string, error) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_verifyWithCode_client_error() {
        let task = MockDataTask()
        let sut = makeSUT()
        let mockTaskFactory: ((URLRequest, @escaping URLDataTaskCompletion) -> F4SNetworkTask) = { request, completion in
            task.request = request
            task.expectedData = nil
            task.completion = completion
            task.expectedResponse = nil
            task.expectedError = F4SError.genericError("")
            return task
        }
        sut.taskfactory = mockTaskFactory
        let expectation = XCTestExpectation(description: "")
        sut.verifyWithCode(email: "wrong email", code: "1234", onSuccess: { (string) in
            expectation.fulfill()
            XCTFail("This test was designed to return an error result")
        }) { (string, error) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK:- helpers
    func submissionErrorFromCode(_ code: Int) -> EmailVerificationService.EmailSubmissionError? {
        return EmailVerificationService.EmailSubmissionError.emailSubmissionError(from: code)
    }
}
