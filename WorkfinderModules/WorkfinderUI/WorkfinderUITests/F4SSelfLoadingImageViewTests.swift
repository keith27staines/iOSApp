import XCTest

@testable import WorkfinderUI

class F4SSelfLoadingImageViewTests: XCTestCase {
    
    func test_fetch_from_nil_urlString() {
        let defaultImage = createImage()
        let imageToFetch = createImage()
        let mockFetcher = MockImageFetcher(imageToFetch: imageToFetch)
        let sut = WFSelfLoadingImageView()
        let expectation = XCTestExpectation(description: "")
        sut.load(urlString: nil, defaultImage: defaultImage, fetcher: mockFetcher) {
            XCTAssertEqual(sut.image, defaultImage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    
    func test_default_image_set_immediately() {
        let defaultImage = createImage()
        let imageToFetch = createImage()
        let mockFetcher = MockImageFetcher(imageToFetch: imageToFetch)
        let sut = WFSelfLoadingImageView()
        sut.load(urlString: "url/url", defaultImage: defaultImage, fetcher: mockFetcher)
        XCTAssertEqual(sut.image, defaultImage)
    }

    func test_fetch_image_success() {
        let defaultImage = createImage()
        let imageToFetch = createImage()
        let mockFetcher = MockImageFetcher(imageToFetch: imageToFetch)
        let sut = WFSelfLoadingImageView()
        let expectation = XCTestExpectation(description: "")
        sut.load(urlString: "url/url", defaultImage: defaultImage, fetcher: mockFetcher) {
            XCTAssertEqual(sut.image, imageToFetch)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetch_cancels_previous_fetch() {
        let defaultImage = createImage()
        let imageToFetch = createImage()
        let originalFetcher = MockImageFetcher(imageToFetch: nil)
        let mockFetcher = MockImageFetcher(imageToFetch: imageToFetch)
        let sut = WFSelfLoadingImageView()
        sut.fetcher = originalFetcher
        let expectation = XCTestExpectation(description: "")
        sut.load(urlString: "url/url", defaultImage: defaultImage, fetcher: mockFetcher) {
            expectation.fulfill()
        }
        XCTAssertTrue(originalFetcher.cancelled)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetch_nil() {
        let defaultImage = createImage()
        let imageToFetch: UIImage? = nil
        let mockFetcher = MockImageFetcher(imageToFetch: imageToFetch)
        let sut = WFSelfLoadingImageView()
        let expectation = XCTestExpectation(description: "")
        sut.load(urlString: "url/url", defaultImage: defaultImage, fetcher: mockFetcher) {
            XCTAssertEqual(sut.image, defaultImage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}

class MockImageFetcher: ImageFetching {
    var cancelled: Bool = false
    var imageFetched: UIImage?
    
    init(imageToFetch: UIImage?) {
        self.imageFetched = imageToFetch
    }
    
    func getImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            completion(self?.imageFetched)
        }
    }
    
    func cancel() {
        cancelled = true
    }
}

func createImage(color: UIColor = UIColor.white, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}
