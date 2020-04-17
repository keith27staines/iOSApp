
import XCTest
@testable import WorkfinderApplyUseCase

class GrammarTests: XCTestCase {

    func test_empty_list() {
        let sut = Grammar()
        let list = [String]()
        XCTAssertEqual(sut.commaSeparatedList(strings: list), "")
    }
    
    func test_one_item_list() {
        let sut = Grammar()
        let list = ["hello"]
        XCTAssertEqual(sut.commaSeparatedList(strings: list), "hello")
    }
    
    func test_two_item_list() {
        let sut = Grammar()
        let list = ["hello","goodbye"]
        XCTAssertEqual(sut.commaSeparatedList(strings: list), "hello and goodbye")
    }
    
    func test_three_item_list() {
        let sut = Grammar()
        let list = ["hello","welcome","goodbye"]
        XCTAssertEqual(sut.commaSeparatedList(strings: list), "hello, welcome, and goodbye")
    }
    
    func test_five_item_list() {
        let sut = Grammar()
        let list = ["1","2","3","4","5"]
        XCTAssertEqual(sut.commaSeparatedList(strings: list), "1, 2, 3, 4, and 5")
    }
}
