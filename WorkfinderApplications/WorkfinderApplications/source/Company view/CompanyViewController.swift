
import UIKit
import WorkfinderCommon
import WorkfinderUI

class CompanyViewController: UIViewController {
    
    lazy var userMessageHandler = UserMessageHandler(presenter: self)
    let presenter: CompanyViewPresenter
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(view: self)
    }
    
    func loadData() {
        userMessageHandler.showLoadingOverlay(self.view)
        presenter.loadData { [weak self] (optionalError) in
            guard let self = self else { return }
            self.userMessageHandler.hideLoadingOverlay()
            self.userMessageHandler.displayOptionalErrorIfNotNil(optionalError, retryHandler: self.loadData)
            self.refreshFromPresenter()
        }
    }
    
    func refreshFromPresenter() {
        
    }
    
    init(presenter: CompanyViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
