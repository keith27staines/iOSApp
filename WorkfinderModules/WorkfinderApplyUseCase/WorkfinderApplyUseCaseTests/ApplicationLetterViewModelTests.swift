//
//  ApplicationLetterViewModelTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
@testable import WorkfinderApplyUseCase

class ApplicationLetterViewModelTests: XCTestCase {

    func test_ApplicationLetterViewModel_Init() {
        let model = MockApplicationLetterModel(isComplete: false, stringToDisplay: "some text")
        let sut = ApplicationLetterViewModel(letterModel: model)
        XCTAssert(sut.model as! MockApplicationLetterModel === model)
    }

}

