//
//  CoordinatingTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 05/02/2020.
//  Copyright © 2020 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon

class CoordinatingTests: XCTestCase {
    
    var parentCoordinator: Coordinating?
    weak var firstChildCoordinator: Coordinating?
    weak var secondChildCoordinator: Coordinating?
    
    override func setUp() {
        super.setUp()
        parentCoordinator = MockCoordindator()
        let firstChild = MockCoordindator()
        let secondChild = MockCoordindator()
        parentCoordinator!.addChildCoordinator(firstChild)
        parentCoordinator!.addChildCoordinator(secondChild)
        firstChildCoordinator = firstChild
        secondChildCoordinator = secondChild
    }
    
    func test_setup() {
        XCTAssertNotNil(parentCoordinator)
        XCTAssertNotNil(firstChildCoordinator)
        XCTAssertNotNil(secondChildCoordinator)
        XCTAssertNotNil(parentCoordinator?.childCoordinators[firstChildCoordinator!.uuid])
        XCTAssertNotNil(parentCoordinator?.childCoordinators[secondChildCoordinator!.uuid])
        XCTAssertEqual(firstChildCoordinator!.parentCoordinator!.uuid, parentCoordinator!.uuid)
        XCTAssertEqual(secondChildCoordinator!.parentCoordinator!.uuid, parentCoordinator!.uuid)
    }
    
    override func tearDown() {
        parentCoordinator = nil
        firstChildCoordinator = nil
        secondChildCoordinator = nil
    }
    
    func test_removeChildren() {
        parentCoordinator!.addChildCoordinator(firstChildCoordinator!)
        parentCoordinator!.addChildCoordinator(secondChildCoordinator!)
        parentCoordinator!.removeChildCoordinator(firstChildCoordinator!)
        parentCoordinator!.removeChildCoordinator(secondChildCoordinator!)
        XCTAssertNil(firstChildCoordinator)
        XCTAssertNil(secondChildCoordinator)
        XCTAssertTrue(parentCoordinator!.childCoordinators.isEmpty)
    }
    
    func test_didFinish() {
        parentCoordinator!.childCoordinatorDidFinish(firstChildCoordinator!)
        XCTAssertNil(firstChildCoordinator)
        XCTAssertNotNil(secondChildCoordinator)
    }

}
