
import XCTest
import WorkfinderCommon
@testable import WorkfinderCoverLetter

class TemplateRendererTests: XCTestCase {

    lazy var parser: TemplateParser = {
        let model = TemplateModel(uuid: "", templateString: sherlockTemplateString, isProject: true, minimumAge: 0)
        return TemplateParser(templateModel: model)
    }()
    
    func test_render_with_populated_and_unpopulated_fields() {
        let sut = makeSUT()
        let rendered = sut.renderToPlainString(with: [
                "villainName": "Moriarty",
                "villainRole": "arch villain",
                "placeName": "Earth",
                "detectiveName": nil,
                "detectiveRole": "detective"
        ])
        XCTAssertEqual(rendered, """
        {{detectiveName}}, the great detective
        hunted the arch villain Moriarty to the ends
        of the Earth
        """)
    }
    
    func makeSUT(with templateString: String = sherlockTemplateString) -> TemplateRenderer {
        return TemplateRenderer(parser: parser)
    }
        
}
