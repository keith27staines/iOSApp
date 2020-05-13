
import UIKit
import WorkfinderCommon
import WorkfinderUI

class OfferViewController: UIViewController {
    weak var coordinator: ApplicationsCoordinator?
    let presenter: OfferPresenterProtocol
    
    init(coordinator: ApplicationsCoordinator, presenter: OfferPresenterProtocol) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
