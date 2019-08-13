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
    
    func test_template_blankWithName_where_name_exists() {
        let choices = [F4SChoice(uuid: "1", value: "choice")]
        let blanks = [
            F4STemplateBlank(name: "blank0", placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial"),
            F4STemplateBlank(name: "blank1", placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial")
        ]
        let sut = F4STemplate(uuid: "uuid", template: "template", blanks: blanks)
        let recoveredBlank = sut.blankWithName("blank0")
        XCTAssertTrue(recoveredBlank?.name == "blank0")
    }
    
    func test_template_blankWithName_where_name_does_not_exist() {
        let choices = [F4SChoice(uuid: "1", value: "choice")]
        let blanks = [
            F4STemplateBlank(name: "blank0", placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial"),
            F4STemplateBlank(name: "blank1", placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial")
        ]
        let sut = F4STemplate(uuid: "uuid", template: "template", blanks: blanks)
        let recoveredBlank = sut.blankWithName("missing")
        XCTAssertNil(recoveredBlank)
    }
    
    func test_template_blankWithName_where_name_is_enumerated_and_present() {
        let choices = [F4SChoice(uuid: "1", value: "choice")]
        let name1 = TemplateBlankName.employmentSkills
        let name2 = TemplateBlankName.jobRole
        let blanks = [
            F4STemplateBlank(name: name1.rawValue, placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial"),
            F4STemplateBlank(name: name2.rawValue, placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial")
        ]
        let sut = F4STemplate(uuid: "uuid", template: "template", blanks: blanks)
        let recoveredBlank = sut.blankWithName(TemplateBlankName.jobRole)
        XCTAssertTrue(recoveredBlank?.name == TemplateBlankName.jobRole.rawValue)
    }
    
    func test_template_blankWithName_where_name_is_enumerated_but_absent() {
        let choices = [F4SChoice(uuid: "1", value: "choice")]
        let name1 = TemplateBlankName.employmentSkills
        let name2 = TemplateBlankName.jobRole
        let blanks = [
            F4STemplateBlank(name: name1.rawValue, placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial"),
            F4STemplateBlank(name: name2.rawValue, placeholder: "", optionType: F4STemplateBlankOptionType.select, maxChoices: 1, choices: choices, initial: "initial")
        ]
        let sut = F4STemplate(uuid: "uuid", template: "template", blanks: blanks)
        let recoveredBlank = sut.blankWithName(TemplateBlankName.personalAttributes)
        XCTAssertNil(recoveredBlank)
    }
}

