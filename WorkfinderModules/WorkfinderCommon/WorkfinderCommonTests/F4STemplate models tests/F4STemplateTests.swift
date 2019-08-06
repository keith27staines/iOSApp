import XCTest
@testable import WorkfinderCommon

class F4STemplateTests: XCTestCase {

    func test_template_initialise() {
        let choices = [F4SChoice(uuid: "1", value: "choice")]
        let blanks = [
            F4STemplateBlank(name: "blank", placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial")
        ]
        let sut = F4STemplate(uuid: "uuid", template: "template", blanks: blanks)
        XCTAssertEqual(sut.uuid, "uuid")
        XCTAssertTrue(sut.blanks.count == blanks.count)
    }
    
}

