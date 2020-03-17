import XCTest
@testable import f4s_workexperience

class PinDownloadFileParserTests: XCTestCase {

    var fileString: String = ""
    var sut: PinDownloadFileParser!
    
    override func setUp() {
        fileString = _makeDownloadFileString()
        sut = try? PinDownloadFileParser(fileString: fileString)
        XCTAssertNotNil(sut)
    }
    
    func test_init_with_valid_file() {
        XCTAssertEqual(sut.fileString, fileString)
    }
    
    func test_init_with_unknown_version() {
        XCTAssertThrowsError(try PinDownloadFileParser(fileString: "version 2.0")) { error in
            XCTAssertEqual(error as! PinDownloadFileParser.CompanyFileParserError, PinDownloadFileParser.CompanyFileParserError.unknownVersion("version 2.0"))
        }
    }
    
    func test_lineCount() {
        XCTAssertEqual(sut.lineCount, 3)
    }
    
    func test_versionString() {
        XCTAssertEqual(sut.versionString, "version: 1.0")
    }
    
    func test_jsonifiedString() {
        XCTAssertEqual(sut.replaceTerminatingSquareBrackets(lineString: _line2), "{\"workplaceUuid1\",1.01,2.02,[\"tagUuid1\",\"tagUuid2\"]}")
        XCTAssertEqual(sut.insertLatitudeLongitudeKeys(lineString: _line2), "[\"workplaceUuid1\",\"lat\":1.01,\"lon\":2.02,\"tags\":[\"tagUuid1\",\"tagUuid2\"]]")
        XCTAssertEqual(sut.jsonifiedString(from: _line2), "{\"workplaceUuid\":\"workplaceUuid1\",\"lat\":1.01,\"lon\":2.02,\"tags\":[\"tagUuid1\",\"tagUuid2\"]}")
    }
    
    func test_jsonFromLineString() {
        let json = sut.pinJsonFromLineString(lineString: _line2)
        XCTAssertEqual(json.workplaceUuid,"workplaceUuid1")
        XCTAssertEqual(json.lat, 1.01)
        XCTAssertEqual(json.lon, 2.02)
        XCTAssertEqual(json.tags, ["tagUuid1","tagUuid2"])
    }
    
    func test_extractPins() {
        let pins = sut.extractPins()
        XCTAssertEqual(pins.count, 2)
    }
}
