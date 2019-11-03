
import XCTest
import WorkfinderCommon
import WorkfinderServices
import WorkfinderAppLogic
import WorkfinderCoordinators
@testable import f4s_workexperience

class AppCoordinatorTests: XCTestCase {
    
    var masterBuilder: TestMasterBuilder!
    
    func testCreateAppCoordinator() {
        masterBuilder = TestMasterBuilder(userIsRegistered: true, versionIsOkay: false )
        let sut = masterBuilder.appCoordinator
        XCTAssertNotNil(sut.window)
        XCTAssertTrue(sut.window.isKeyWindow)
    }
    
    func test_versionCheck_called_and_onboarding_not_called_when_version_invalid() {
        masterBuilder = TestMasterBuilder(userIsRegistered: false, versionIsOkay: false)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let versionCheckCoordinator = masterBuilder.mockVersionCheckCoordinator as! MockVersionCheckCoordinator
        let masterBuilder = self.masterBuilder!
        versionCheckCoordinator.testVersionCheckWasCalled = {
            let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
            XCTAssertNil(onboardingCoordinator)
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1)
    }
    
    func test_versionCheck_called_and_onboarding_started_when_version_valid() {
        masterBuilder = TestMasterBuilder(userIsRegistered: false, versionIsOkay: true)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let versionCheckCoordinator = masterBuilder.mockVersionCheckCoordinator as! MockVersionCheckCoordinator
        let masterBuilder = self.masterBuilder!
        versionCheckCoordinator.testVersionCheckWasCalled = {
            let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
            XCTAssertTrue(onboardingCoordinator?.startedCount == 1)
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1)
    }
    
    func test_ensureDeviceIsRegistered_is_called() {
        masterBuilder = TestMasterBuilder(userIsRegistered: false, versionIsOkay: true)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let masterBuilder = self.masterBuilder!
        let appInstallationLogic = masterBuilder.mockAppInstallationLogic
        appInstallationLogic.testDidComplete = {
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1000)
    }
    
    func test_tabBar_created_when_onboardingFinishes() {
        masterBuilder = TestMasterBuilder(userIsRegistered: true, versionIsOkay: true)
        let sut = masterBuilder.appCoordinator
        let expectation = XCTestExpectation(description: "")
        let versionCheckCoordinator = masterBuilder.mockVersionCheckCoordinator as! MockVersionCheckCoordinator
        let masterBuilder = self.masterBuilder!
        versionCheckCoordinator.testVersionCheckWasCalled = {
            let onboardingCoordinator = masterBuilder.mockOnboardingCoordinatorFactory.onboardingCoordinators.last
            onboardingCoordinator?.completeOnboarding()
            XCTAssertNotNil(sut.tabBarCoordinator)
            expectation.fulfill()
        }
        sut.start()
        wait(for: [expectation], timeout: 1)
    }

}
