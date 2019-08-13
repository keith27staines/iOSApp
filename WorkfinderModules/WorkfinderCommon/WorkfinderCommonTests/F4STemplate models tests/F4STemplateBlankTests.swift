import XCTest
@testable import WorkfinderCommon

class F4STemplateBlankTests: XCTestCase {
    func test_templateBlank_initialise() {
        let choices = [F4SChoice(uuid: "choiceUuid", value: "choiceValue")]
        let sut = F4STemplateBlank(name: "name", placeholder: "placeholder", optionType: F4STemplateBlankOptionType.select, maxChoices: 3, choices: choices, initial: "initialValue")
        XCTAssertTrue(sut.name == "name")
        XCTAssertTrue(sut.maxChoices == 3)
        XCTAssertTrue(sut.choices.first!.uuid == choices.first!.uuid)
        XCTAssertTrue(sut.initialValue == "initialValue")
        XCTAssertTrue(sut.optionType == .select)
        XCTAssertTrue(sut.placeholder == "placeholder")
    }
    
    func test_templateBlank_remove_choice() {
        let choices = [
            F4SChoice(uuid: "choiceUuid0", value: "choiceValue"),
            F4SChoice(uuid: "choiceUuid1", value: "choiceValue"),
            F4SChoice(uuid: "choiceUuid2", value: "choiceValue")
        ]
        var sut = F4STemplateBlank(name: "name", placeholder: "placeholder", optionType: F4STemplateBlankOptionType.select, maxChoices: 3, choices: choices, initial: "initialValue")
        sut.removeChoiceWithUuid("choiceUuid1")
        XCTAssertEqual(sut.choices.count, 2)
        XCTAssertEqual(sut.choices[0].uuid, "choiceUuid0")
        XCTAssertEqual(sut.choices[1].uuid, "choiceUuid2")
    }
    
    func test_templateBlank_remove_unexpcted_choice() {
        let choices = [
            F4SChoice(uuid: "choiceUuid0", value: "choiceValue"),
            F4SChoice(uuid: "choiceUuid1", value: "choiceValue"),
            F4SChoice(uuid: "choiceUuid2", value: "choiceValue")
        ]
        var sut = F4STemplateBlank(name: "name", placeholder: "placeholder", optionType: F4STemplateBlankOptionType.select, maxChoices: 3, choices: choices, initial: "initialValue")
        sut.removeChoiceWithUuid("unexpected")
        XCTAssertTrue(sut.choices.count == 3)
    }
}
