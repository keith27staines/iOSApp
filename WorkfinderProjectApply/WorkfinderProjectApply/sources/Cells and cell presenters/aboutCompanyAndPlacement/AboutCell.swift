
import UIKit

class AboutCell: SimpleTextCell {
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        guard let presenter = presenter as? AboutPresenterProtocol else { return }
        Style.body.text.applyTo(label: label)
        label.text = presenter.text
        label.numberOfLines = 0
    }
    
    override func configureViews() {
        super.configureViews()
    }
}
