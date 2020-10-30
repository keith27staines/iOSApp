
import UIKit

protocol ProjectHeaderPresenterProtocol: CellPresenterProtocol {
    var attributedTitle: NSAttributedString { get }
}

class ProjectHeaderPresenter: ProjectHeaderPresenterProtocol {
    
    private let companyName: String
    private let projectName: String
    var isHidden: Bool
    
    lazy var attributedTitle: NSAttributedString = {
        var attributes = Style.projectHeading.text.attributes
        let string1 = NSAttributedString(string: "\(projectName) with ", attributes: attributes)
        attributes = Style.projectHeadingEmphasised.text.attributes
        let string2 = NSAttributedString(string: companyName, attributes: attributes)
        var concatenated = NSMutableAttributedString(attributedString: string1)
        concatenated.append(string2)
        return concatenated
    }()
    
    init(companyName: String?, projectName: String?, isHidden: Bool = false) {
        self.companyName = companyName ?? ""
        self.projectName = projectName ?? ""
        self.isHidden = isHidden
    }
    
}
