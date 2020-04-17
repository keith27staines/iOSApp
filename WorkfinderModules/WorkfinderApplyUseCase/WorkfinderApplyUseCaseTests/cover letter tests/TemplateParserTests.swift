
import XCTest
@testable import WorkfinderApplyUseCase

class TemplateParserTests: XCTestCase {
    
    let startDelimiter = TemplateField.DelimiterType.start
    let endDelimiter = TemplateField.DelimiterType.end
    let startString = TemplateField.DelimiterType.start.rawValue
    let endString = TemplateField.DelimiterType.end.rawValue
    
    func test_range_of_start_is_nil_for_empty_string() {
        let sut = makeSUT(with: "")
        XCTAssertNil(sut.findRangeOfNextDelimiterOfType(startDelimiter))
    }
    
    func test_range_of_start_delimiter_for_string_with_no_start_delimiter() {
        let sut = makeSUT(with: "just some text")
        let firstStartDelimiterRange = sut.findRangeOfNextDelimiterOfType(.start)
        XCTAssertNil(firstStartDelimiterRange)
    }
    
    func test_range_of_start_delimiter_for_string_starting_with_start_delimiter() {
        let sut = makeSUT()
        let delimiterRange = sut.findRangeOfNextDelimiterOfType(.start)
        XCTAssertEqual(delimiterRange?.lowerBound, sherlockTemplateString.startIndex)
    }
    
    func test_first_field_in_template() {
        let sut = makeSUT()
        XCTAssertEqual(sut.nextFieldString(), "{{detectiveName}}")
    }
    
    func test_allFields() {
        let sut = makeSUT()
        let allFieldRanges = sut.allFieldRanges()
        XCTAssertEqual(allFieldRanges.count, 5)
    }
    
    func test_allFields_automatically_resets_start() {
        let sut = makeSUT()
        let _ = sut.searchStart = sut.searchEnd
        let allFieldRanges = sut.allFieldRanges()
        XCTAssertEqual(allFieldRanges.count, 5)
    }
    
    func test_all_field_strings() {
        let sut = makeSUT()
        let _ = sut.searchStart = sut.searchEnd
        XCTAssertEqual(sut.allFieldStrings()[0], "{{detectiveName}}")
        XCTAssertEqual(sut.allFieldStrings()[1], "{{detectiveRole}}")
        XCTAssertEqual(sut.allFieldStrings()[2], "{{villainRole}}")
        XCTAssertEqual(sut.allFieldStrings()[3], "{{villainName}}")
        XCTAssertEqual(sut.allFieldStrings()[4], "{{placeName}}")
    }
    
    func test_all_field_names() {
        let sut = makeSUT()
        let _ = sut.searchStart = sut.searchEnd
        XCTAssertEqual(sut.allFieldNames()[0], "detectiveName")
        XCTAssertEqual(sut.allFieldNames()[1], "detectiveRole")
        XCTAssertEqual(sut.allFieldNames()[2], "villainRole")
        XCTAssertEqual(sut.allFieldNames()[3], "villainName")
        XCTAssertEqual(sut.allFieldNames()[4], "placeName")
    }
    
    func makeSUT(with templateString: String = sherlockTemplateString) -> TemplateParser {
        let templateModel = TemplateModel(uuid: "", templateString: templateString)
        let sut = TemplateParser(templateModel: templateModel)
        return sut
    }
}


