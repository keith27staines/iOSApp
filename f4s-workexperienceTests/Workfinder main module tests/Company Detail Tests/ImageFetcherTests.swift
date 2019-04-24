//
//  ImageFetcherTests.swift
//  F4SPrototypesTests
//
//  Created by Keith Dev on 27/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import XCTest
@testable import f4s_workexperience

class ImageFetcherTests: XCTestCase {
    
    var sut: ImageFetcher!
    var defaultImage: UIImage!
    var badUrl: URL!
    var configuration: URLSessionConfiguration!
    var mockSession: MockURLSession!
    var mockDataTask: MockURLSessionDataTask!
    var fetchedImageData: Data!
    var fetchedImage: UIImage!
    
    override func setUp() {
        super.setUp()
        badUrl = URL(string: "badUrl")
        defaultImage = #imageLiteral(resourceName: "companyLogo")
        fetchedImageData = #imageLiteral(resourceName: "ratingFilledStar").pngData()
        fetchedImage = UIImage(data: fetchedImageData)
        configuration = URLSessionConfiguration.default
        mockDataTask = MockURLSessionDataTask()
        mockSession = MockURLSession(configuration: configuration)
        mockSession.dataTask = mockDataTask
    }
    
    override func tearDown() {
        sut = nil
        badUrl = nil
        defaultImage = nil
        fetchedImageData = nil
        fetchedImage = nil
        configuration = nil
        mockSession = nil
        mockDataTask = nil
        super.tearDown()
    }

    func test_defaultImage_afterInitialization() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        XCTAssertEqual(sut.defaultImage,defaultImage)
    }
    
    func test_sourceUrl_afterInitialization() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        XCTAssertEqual(sut.source, badUrl)
    }
    
    func test_session_afterinitializationWithoutSessionInjection() {
        sut = ImageFetcher(from: badUrl, session: nil, defaultImage: defaultImage)
        XCTAssertNotNil(sut.session)
    }
    
    func test_session_afterinitializationWithSessionInjection() {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        sut = ImageFetcher(from: badUrl, session: session, defaultImage: nil)
        XCTAssertEqual(sut.session.configuration, session.configuration)
    }
    
    func test_defaultImageAfterInitializationWithoutDefaultImageInjection() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: nil)
        XCTAssertNil(sut.defaultImage)
    }
    
    func test_defaultImageAfterInitializationWithDefaultImageInjection() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        XCTAssertEqual(defaultImage, sut.defaultImage)
    }
    
    func test_StateBeforeFetch() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        XCTAssertFalse(sut.isFetching)
        XCTAssertEqual(mockDataTask.resumeCount,0)
        XCTAssertEqual(mockDataTask.cancelCount, 0)
    }
    
    func test_StateDuringFetch() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        sut.fetch(completion: {image in})
        XCTAssertTrue(sut.isFetching)
        XCTAssertEqual(mockDataTask.resumeCount,1)
        XCTAssertEqual(mockDataTask.cancelCount, 0)
    }
    
    func test_StateAfterBadFetch() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        mockDataTask.data = nil
        let expectation = XCTestExpectation(description: "test_StateAfterBadFetch")
        sut.fetch(completion: {[weak self] image in
            XCTAssertEqual(image, self?.defaultImage)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(sut.isFetching)
        XCTAssertEqual(mockDataTask.resumeCount,1)
        XCTAssertEqual(mockDataTask.cancelCount, 0)
    }
    
    func test_GoodFetch() {
        sut = ImageFetcher(from: badUrl, session: mockSession, defaultImage: defaultImage)
        mockDataTask.data = fetchedImageData
        let expectation = XCTestExpectation(description: "test_GoodFetch")
        sut.fetch {[weak self] (image) in
            let identical = self?.checkImagePNGDataAreIdentical(image1: image, image2: self!.fetchedImage) ?? false
            XCTAssertTrue(identical)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(true)
    }
 
    func checkImagePNGDataAreIdentical(image1: UIImage?, image2: UIImage?) -> Bool {
        guard
            let image1Data = image1?.pngData(),
            let image2Data = image2?.pngData(),
            image1Data.count == image2Data.count else {
            return false
        }
        for (index,b) in image1Data.enumerated() {
            if b != image2Data[index] { return false }
        }
        return true
    }

}

class MockURLSession : URLSessionProtocol {
    
    var configuration: URLSessionConfiguration
    var dataTask: MockURLSessionDataTask?
    
    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
    
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        guard let dataTask = dataTask else {
            preconditionFailure("The dataTask is nil. You must inject a prepared MockURLSessionDataTask before calling makeDataTask")
        }
        dataTask.completionHandler = completionHandler
        return dataTask
    }
}

class MockURLSessionDataTask : URLSessionDataTaskProtocol {
    
    var resumeCount: Int = 0
    var cancelCount: Int = 0
    var data: Data? = nil
    var response: HTTPURLResponse? = nil
    var error: Error? = nil
    fileprivate var completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil
    private var queue: DispatchQueue?
    func resume() {
        XCTAssertEqual(cancelCount, 0, "Resume was called afer cancel. This is illegal")
        XCTAssertEqual(resumeCount, 0, "Resume was called twice. This is illegal")
        resumeCount += 1
        queue = DispatchQueue.init(label: "MockURLSessionDataTask")
        queue?.async { [weak self] in
            guard let this = self else { return }
            this.completionHandler?(this.data,this.response,this.error)
        }
    }
    
    func cancel() {
        cancelCount += 1
    }
}
