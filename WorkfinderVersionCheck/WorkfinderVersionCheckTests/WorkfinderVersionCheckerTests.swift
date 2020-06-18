
import XCTest
@testable import WorkfinderVersionCheck

class WorkfinderVersionCheckerTests: XCTestCase {
    
    func makeSut(
        appVersionString: String,
        minimumVersionString: String) -> WorkfinderVersionChecker {
        let serverVersion = VersionJson(platform: "iOS", min_version: minimumVersionString)
        let fetchResult = Result<VersionJson,Error>.success(serverVersion)
        let service = MockVersionCheckService(fetchResult: fetchResult)
        let sut = WorkfinderVersionChecker(
            serverEnvironmentType: .staging,
            currentVersion: appVersionString,
            versionCheckService: service)
        return sut
    }
    
    func test_initialise() {
        let sut = makeSut(appVersionString: "", minimumVersionString: "")
        XCTAssertNotNil(sut.service as? MockVersionCheckService)
    }
    
    func test_checkVersion_when_minimum_version() {
        let minimumVersionString = "3.1.0"
        let minimumVersion = Version(string: minimumVersionString)
        let appVersion = minimumVersion
        let sut = makeSut(appVersionString: "", minimumVersionString: "")
        let result = sut.checkVersion(appVersion, minimumVersion: minimumVersion)
        XCTAssertEqual(result, .good)
    }
    
    func test_checkVersion_when_greater_than_minimum_version() {
        let sut = makeSut(appVersionString: "", minimumVersionString: "")
        let minimumVersionString = "3.1.0"
        let minimumVersion = Version(string: minimumVersionString)
        let appVersion = Version(major: 4, minor: 0, revision: 0)
        let result = sut.checkVersion(appVersion, minimumVersion: minimumVersion)
        XCTAssertEqual(result, .good)
    }
    
    func test_checkVersion_when_less_than_minimum_version() {
        let sut = makeSut(appVersionString: "", minimumVersionString: "")
        let minimumVersionString = "3.1.0"
        let minimumVersion = Version(string: minimumVersionString)
        let appVersion = Version(major: 2, minor: 0, revision: 0)
        let result = sut.checkVersion(appVersion, minimumVersion: minimumVersion)
        XCTAssertEqual(result, .bad)
    }
    
    func test_performCheckWithHardStop_version_is_valid() {
        let sut = makeSut(appVersionString: "3.1.0",
                          minimumVersionString: "3.1.0")
        let expectation = self.expectation(description: "")
        sut.performChecksWithHardStop { (error) in
            expectation.fulfill()
            XCTAssertNil(error)
        }
        waitForExpectations(timeout: 0.01)
    }
    
    func test_performCheckWithHardStop_version_is_not_valid() {
        let sut = makeSut(appVersionString: "0.0.0",
                          minimumVersionString: "3.0.1")
        let expectation = self.expectation(description: "")
        expectation.isInverted = true
        sut.performChecksWithHardStop { (error) in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.01)
    }
}

class MockVersionCheckService: VersionCheckServiceProtocol {
    
    let fetchResult: Result<VersionJson, Error>
    
    init(fetchResult: Result<VersionJson, Error>) {
        self.fetchResult = fetchResult
    }
    
    func fetchMinimumVersion(completion: @escaping (Result<VersionJson, Error>) -> Void) {
        completion(fetchResult)
    }
}
