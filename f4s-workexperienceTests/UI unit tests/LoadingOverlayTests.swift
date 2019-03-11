//
//  LoadingOverlayTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 27/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest

@testable import f4s_workexperience

class LoadingOverlayTests : XCTestCase {
    
    func testInit() {
        _ = LoadingOverlay()
        XCTAssert(true)
    }
    
    func testSetCaptionAfterShowOverlay() {
        let sut = LoadingOverlay()
        sut.showOverlay()
        sut.caption = "something"
    }

    func testSetCaptionBeforeShowOverlay() {
        let sut = LoadingOverlay()
        sut.caption = "something"
        sut.showOverlay()
    }
    
    func testCaptionLabelIsHiddenIfCaptionNotSet() {
        let sut = LoadingOverlay()
        sut.showOverlay()
        XCTAssertTrue(sut.captionLabel.isHidden)
    }
    
    func testCaptionLabelIsVisisbleIfCaptionSet() {
        let sut = LoadingOverlay()
        sut.showOverlay()
        sut.caption = "hello"
        XCTAssertFalse(sut.captionLabel.isHidden)
    }
    
    func testActivityIndicatorIsVisible() {
        let sut = LoadingOverlay()
        sut.showOverlay()
        XCTAssertFalse(sut.activityIndicator.isHidden)
    }
    
    func testSameFrameAsSuperview() {
        let sut = LoadingOverlay()
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        let superview = UIView(frame: frame)
        superview.addSubview(sut)
        sut.showOverlay()
        superview.layoutIfNeeded()
        XCTAssertEqual(sut.frame, superview.frame)
    }
    
}
