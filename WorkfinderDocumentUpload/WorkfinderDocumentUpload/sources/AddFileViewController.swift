
import UIKit
import WorkfinderUI

protocol AddFileViewControllerProtocol: class {
    func refresh()
}

class AddFileViewController: UIViewController, AddFileViewControllerProtocol {
    
    let presenter: AddFilePresenter
    var coordinator: DocumentUploadCoordinator?
    
    func refresh() {
        
    }
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(view: self)
    }
    
    init(coordinator: DocumentUploadCoordinator, presenter: AddFilePresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")
    }
    
}
