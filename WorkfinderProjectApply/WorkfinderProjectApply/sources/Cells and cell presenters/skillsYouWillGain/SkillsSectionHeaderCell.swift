
import UIKit

class SkillsSectionHeaderCell: SectionHeadingCell {
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol, width: CGFloat) {
        guard let presenter = presenter as? SectionHeadingPresenterProtocol else { return }
        Style.skillsSectionHeading.text.applyTo(label: label)
        label.text = presenter.title
    }
}
