//
//  VersionCheckCoordinatorTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 08/07/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon

@testable import f4s_workexperience

class VersionCheckCoordinatorTests: XCTestCase {

    var parentCoordinator: MockParentCoordinator!
    var router: MockNavigationRouter!
    
    func test_VersionIsGood() {
        let sut = makeSUTVersionCheckCoordinator()
        sut.versionCheckService = MockVersionCheckingService(versionIsGood: true)
        let vesionCheckComplete = XCTestExpectation(description: "version check complete")
        sut.versionCheckCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                XCTAssertFalse(false, "Unexpected error \(error)")
            case .success(let isVersionGood):
                XCTAssertTrue(isVersionGood, "")
                XCTAssertEqual(strongSelf.router.pushedViewControllers.count, 0)
                XCTAssertEqual(strongSelf.router.presentedViewControllers.count, 0)
                XCTAssertEqual(strongSelf.parentCoordinator.childCoordinators.count, 0)
            }
            vesionCheckComplete.fulfill()
        }
        sut.start()
        wait(for: [vesionCheckComplete], timeout: 1)
    }
    
    func test_VersionIsBad() {
        let sut = makeSUTVersionCheckCoordinator()
        sut.versionCheckService = MockVersionCheckingService(versionIsGood: false)
        let vesionCheckComplete = XCTestExpectation(description: "version check complete")
        sut.versionCheckCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                XCTAssertFalse(false, "Unexpected error \(error)")
            case .success(let isVersionGood):
                XCTAssertFalse(isVersionGood, "")
            }
            XCTAssertEqual(strongSelf.router.pushedViewControllers.count, 0)
            XCTAssertEqual(strongSelf.router.presentedViewControllers.count, 1)
            XCTAssertEqual(strongSelf.parentCoordinator.childCoordinators.count, 1)
            vesionCheckComplete.fulfill()
        }
        sut.start()
        wait(for: [vesionCheckComplete], timeout: 1)
    }
    
    func makeSUTVersionCheckCoordinator() -> VersionCheckCoordinator {
        router = MockNavigationRouter()
        parentCoordinator = MockParentCoordinator(router: router!)
        let sut = VersionCheckCoordinator(parent: parentCoordinator, navigationRouter: router!)
        parentCoordinator.addChildCoordinator(sut)
        return sut
    }
}


