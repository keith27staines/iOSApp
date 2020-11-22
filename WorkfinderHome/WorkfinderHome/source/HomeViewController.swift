
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderOnboardingUseCase

class HomeViewController: UIViewController {

    let screenName = ScreenName.map
    weak var coordinator: HomeCoordinator?
    var homeView: HomeView { view as! HomeView }
    lazy var messageHandler = UserMessageHandler(presenter: self)
    override func loadView() { view = HomeView() }
    
    override func viewDidLoad() {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    var isConfigured = false
    func configureViews() {
        adjustNavigationBar()
        guard !isConfigured else { return }
        isConfigured = true
        homeView.configureViews()
        homeView.headerView.height = (navigationBar?.frame.height ?? 0) + statusBarHeight
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}

extension HomeViewController {
    var navigationBar: UINavigationBar? { navigationController?.navigationBar }
    var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationBar?.barTintColor = UIColor.black
        navigationBar?.tintColor = UIColor.white
        navigationBar?.isTranslucent = false
        setNeedsStatusBarAppearanceUpdate()
    }
}
