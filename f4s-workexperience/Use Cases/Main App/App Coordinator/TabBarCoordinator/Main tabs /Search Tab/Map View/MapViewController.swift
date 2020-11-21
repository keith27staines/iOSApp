
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderOnboardingUseCase

class MapViewController: UIViewController {

    let screenName = ScreenName.map
    weak var coordinator: SearchCoordinator?
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
    }
    
    var discoveryView: DiscoveryView?
    func addDiscoveryView() {
        guard self.discoveryView == nil else { return }
        let discoveryView = DiscoveryView()
        self.view.addSubview(discoveryView)
        self.discoveryView = discoveryView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDiscoveryView()
    }
    
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
}


