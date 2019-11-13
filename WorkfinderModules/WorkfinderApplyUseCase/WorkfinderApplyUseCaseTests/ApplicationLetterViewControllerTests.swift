//
//  ApplicationLetterViewControllerTests.swift
//  f4s-workexperienceTests
//
//  Created by Keith Dev on 23/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import XCTest
import WorkfinderCommon
@testable import WorkfinderApplyUseCase

class ApplicationLetterViewControllerTests: XCTestCase {
    
    let coordinator = MockApplicationLetterCoordinator()
    
    func test_ApplicationLetterViewController_coordinatorSetOnInit() {
        let sut = makeSUT()
        XCTAssertNotNil(sut.coordinator)
    }
    
    func test_ApplicationLetterViewController_editLetterButton() {
        let sut = makeSUT()
        XCTAssertTrue(sut.editButton.allTargets.contains(sut))
        XCTAssertTrue(sut.editButton.isEnabled)
        XCTAssertFalse(sut.editButton.isHidden)
    }
    
    func test_ApplicationLetterViewController_editLetterButton_CallsCoordinatorOnEditLetterTap() {
        let sut = makeSUT()
        sut.editButtonTapped(sender: nil)
        XCTAssertEqual(coordinator.editButtonTapCount, 1)
    }
    
    func test_ApplicationLetterViewController_applyButtonTarget() {
        let sut = makeSUT()
        XCTAssertTrue(sut.applyButton.allTargets.contains(sut))
    }
    
    func test_ApplicationLetterViewController_applyButtonConfigurationWithIncompleteLetter() {
        let sut = makeSUT()
        XCTAssertFalse(sut.applyButton.isEnabled)
        XCTAssertFalse(sut.applyButton.isHidden)
    }
    
    func test_ApplicationLetterViewController_applyButtonEnabled() {
        let sut = makeSUT(isComplete: true)
        let mockViewModel = sut.viewModel as! MockApplicationLetterViewModel
        mockViewModel.applyButtonIsEnabled = true
        sut.updateFromViewModel()
        XCTAssertTrue(sut.applyButton.isEnabled)
    }
    
    func test_ApplicationLetterViewController_applyButtonDisabled() {
        let sut = makeSUT(isComplete: true)
        let mockViewModel = sut.viewModel as! MockApplicationLetterViewModel
        mockViewModel.applyButtonIsEnabled = false
        sut.updateFromViewModel()
        XCTAssertFalse(sut.applyButton.isEnabled)
    }
    
    
    func test_ApplicationLetterViewController_termsAndConditionsButton_stateWhenLetterIsNotComplete() {
        let sut = makeSUT()
        assertTermsAndConditionsButtonState(sut: sut, expectedTapCount: 0)
    }
    
    func test_ApplicationLetterViewController_termsAndConditionsButton_stateWhenLetterIsComplete() {
        let sut = makeSUT()
        assertTermsAndConditionsButtonState(sut: sut, expectedTapCount: 0)
    }
    
    func test_ApplicationLetterViewController_termsAndConditionsButton_callsCoordinatorOnTap() {
        let sut = makeSUT()
        sut.termsAndConditionsButtonTapped(sender: self)
        assertTermsAndConditionsButtonState(sut: sut, expectedTapCount: 1)
    }
    
    func test_ApplicationLetterViewController_cancelButton_stateWhenLetterIsNotComplete() {
        let sut = makeSUT()
        assertCancelButtonState(sut: sut, expectedTapCount: 0)
    }
    
    func test_ApplicationLetterViewController_cancelButton_stateWhenLetterIsComplete() {
        let sut = makeSUT(isComplete: true)
        assertCancelButtonState(sut: sut, expectedTapCount: 0)
    }
    
    func test_ApplicationLetterViewController_cancelButton_callsCoordinatorOnTap() {
        let sut = makeSUT()
        sut.cancelButtonTapped(sender: self)
        assertCancelButtonState(sut: sut, expectedTapCount: 1)
    }
    
    func test_ApplicationLetterViewController_view() {
        let sut = makeSUT()
        XCTAssertNotNil(sut.view)
    }
    
    func test_ApplicationLetterViewController_textViewDisplaysTextFromModel() {
        let sut = makeSUT(isComplete: false, stringToDisplay: "fhdjkshfdjksa fjdsajfkdlsa fhdurenhuerij")
        sut.updateFromViewModel()
        XCTAssertEqual(sut.textView.text,"fhdjkshfdjksa fjdsajfkdlsa fhdurenhuerij")
    }
}

extension ApplicationLetterViewControllerTests {
    func makeSUT(isComplete: Bool = false, stringToDisplay: String = "test") -> ApplicationLetterViewController {
        let model = MockApplicationLetterModel(isComplete: isComplete, stringToDisplay: stringToDisplay)
        let viewModel = MockApplicationLetterViewModel(model: model)
        viewModel.attributedText = NSAttributedString(string: stringToDisplay)
        let vc = ApplicationLetterViewController(coordinator: coordinator, viewModel: viewModel)
        _ = vc.view
        return vc
    }
    
    func assertTermsAndConditionsButtonState(sut: ApplicationLetterViewController, expectedTapCount: Int) {
        XCTAssertTrue(sut.termsAndConditionsButton.allTargets.contains(sut))
        XCTAssertTrue(sut.termsAndConditionsButton.isEnabled)
        XCTAssertFalse(sut.termsAndConditionsButton.isHidden)
        let mockViewModel = sut.viewModel as! MockApplicationLetterViewModel
        XCTAssertEqual(mockViewModel.termsAndConditionsButtonWasTappedCallCount, expectedTapCount)
    }
    
    func assertCancelButtonState(sut: ApplicationLetterViewController, expectedTapCount: Int) {
        XCTAssertTrue(sut.cancelButton.allTargets.contains(sut))
        XCTAssertTrue(sut.cancelButton.isEnabled == true)
        XCTAssertFalse(sut.cancelButton.isHidden)
        XCTAssertEqual(coordinator.cancelButtonTapCount, expectedTapCount)
    }
}

class MockApplicationLetterViewModel : ApplicationLetterViewModelProtocol {

    
    func modelBusyState(_ model: ApplicationLetterModelProtocol, isBusy: Bool) {
        
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, stoppedProcessingWithError: Error) {
        
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, renderedTemplateToString: NSAttributedString, allFieldsFilled: Bool) {
        
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, failedToSubmitLetter error: F4SNetworkError, retry: (() -> Void)?) {
        
    }
    
    var view: ApplicationLetterViewProtocol?
    var model: ApplicationLetterModelProtocol
    var coordinator: ApplicationLetterViewControllerCoordinating? 
    var applyButtonIsEnabled: Bool = false
    var attributedText: NSAttributedString = NSAttributedString()
    var termsAndConditionsButtonWasTappedCallCount: Int = 0
    var applyButtonTapCallCount: Int = 0
    var onViewDidLoadCallCount: Int = 0
    
    init(model: ApplicationLetterModelProtocol) {
        self.model = model
    }
    
    func applyButtonWasTapped() {
        applyButtonTapCallCount += 1
    }
    
    func termsAndConditionsButtonWasTapped(sender: Any) {
        termsAndConditionsButtonWasTappedCallCount += 1
    }
    
    func onViewDidLoad() {
        onViewDidLoadCallCount += 1
    }
}

class MockBlanksModel : ApplicationLetterTemplateBlanksModelProtocol {
    func updateMotivationBlank(_ text: String) {
        
    }
    
    
    func updateBlanksFor(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
    }
    
    var template: F4STemplate?
    
    func setTemplate(_ template: F4STemplate) -> Bool {
        return false
    }
    
    func populatedBlanks() -> [F4STemplateBlank] {
        return []
    }
    
    func templateBlankWithName(_ name: TemplateBlankName) -> F4STemplateBlank? {
        return nil
    }
    
    func templateBlankWithName(_ name: String) -> F4STemplateBlank? {
        return nil
    }
    
    func populatedBlankWithName(_ name: TemplateBlankName) -> F4STemplateBlank? {
        return nil
    }
    
    func addOrReplacePopulatedBlanks(_ blanks: [F4STemplateBlank]) throws {
        
    }
    
    func addOrReplacePopulatedBlank(_ blank: F4STemplateBlank) throws {
        
    }
    
    
}

class MockApplicationLetterModel :  ApplicationLetterModelProtocol {
    var blanksModel: ApplicationLetterTemplateBlanksModelProtocol = MockBlanksModel()
    
    var letterString: NSAttributedString
    var allFieldsFilled: Bool
    weak var delegate: ApplicationLetterModelDelegate?
    
    func render() {}
    
    init(isComplete: Bool, stringToDisplay: String) {
        letterString = NSAttributedString(string: stringToDisplay)
        self.allFieldsFilled = isComplete
    }
}

class MockApplicationLetterCoordinator : ApplicationLetterViewControllerCoordinating {
    
    var editButtonTapCount = 0
    var termsAndsConditionsButtonTapCount = 0
    var cancelButtonTapCount = 0
    var continueApplicationWithCompletedLetterCallCount: Int = 0
    
    func continueApplicationWithCompletedLetter(sender: Any?, completion: @escaping (Error?) -> Void) {
        continueApplicationWithCompletedLetterCallCount += 1
    }
    
    func cancelButtonWasTapped(sender: Any?) {
        cancelButtonTapCount += 1
    }
    
    func editButtonWasTapped(sender: Any?) {
        editButtonTapCount += 1
    }
    
    func termsAndConditionsWasTapped(sender: Any?) {
        termsAndsConditionsButtonTapCount += 1
    }
}
