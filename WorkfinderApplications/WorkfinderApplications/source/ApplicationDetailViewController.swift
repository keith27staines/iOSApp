import UIKit

class ApplicationDetailViewController: UIViewController {
    let state: ApplicationState
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = self.state.description
        return label
    }()
    
    init(state: ApplicationState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.title = state.screenTitle
        configureViews()
    }
    
    func configureViews() {
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
