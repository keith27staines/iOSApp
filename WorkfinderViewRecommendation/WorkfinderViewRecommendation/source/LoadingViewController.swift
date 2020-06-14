
import UIKit
import WorkfinderCommon
import WorkfinderUI

class LoadingViewController: UIViewController {
    
    lazy var userMessageHandler = UserMessageHandler(presenter: self)
    let presenter: LoadingViewPresenter
    
    init(presenter: LoadingViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        presenter.onViewDidLoad(self)
        configureNaviationBar()
        loadData()
    }
    
    func loadData() {
        userMessageHandler.showLoadingOverlay(self.view)
        presenter.loadData() { [weak self] optionalError in
            guard let self = self else { return }
            self.userMessageHandler.hideLoadingOverlay()
            self.userMessageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.loadData()
            }
        }
    }
    
    func configureNaviationBar() {
        self.title = "Loading Recommendation"
//        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
//        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
