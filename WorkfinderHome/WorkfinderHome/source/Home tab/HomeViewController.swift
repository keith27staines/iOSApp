
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HomeViewController: UIViewController {

    let screenName = ScreenName.home
    weak var coordinator: HomeCoordinator?
    lazy var messageHandler = UserMessageHandler(presenter: self)

    var homeView: HomeView { view as! HomeView }
    var headerView: HeaderView { homeView.headerView }
    var backgroundView: BackgroundView { homeView.backgroundView }
    
    lazy var trayController: DiscoveryTrayController = DiscoveryTrayController()
    var tray: DiscoveryTrayView { trayController.tray }
    
    lazy var trayTopConstraint: NSLayoutConstraint = {
        let constraint = tray.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0)
        constraint.isActive = true
        return constraint
    }()
    
    var trayTopConstraintConstant: CGFloat = 0 {
        didSet {
            let guide = homeView.backgroundView.safeAreaLayoutGuide
            trayTopConstraintConstant = max(guide.layoutFrame.minY + 0, trayTopConstraintConstant)
            trayTopConstraintConstant = min(guide.layoutFrame.maxY - 40, trayTopConstraintConstant)
            trayTopConstraint.constant = trayTopConstraintConstant
            if trayTopConstraintConstant < 100 {
                homeView.headerVerticalOffset = -(100 - trayTopConstraintConstant)/2
                headerView.alpha = 1 - 2*(100 - trayTopConstraintConstant)/100
                
            } else {
                homeView.headerVerticalOffset = 0
                headerView.alpha = 1
            }
        }
    }
    
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        return pan
    }()
    
    var lastLocation: CGPoint?
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: homeView)
        let velocity = sender.velocity(in: homeView)
        guard abs(velocity.y) > abs(velocity.x) else { return }
        if sender.state == .began {
            lastLocation = location
        } else if sender.state == .changed {
            trayTopConstraintConstant += location.y - (lastLocation?.y ?? 0)
            lastLocation = location
        } else if sender.state == .ended {
            lastLocation = nil
            animateTrayToFinalPosition()
        }
    }
    
    func animateTrayToFinalPosition() {
        if trayTopConstraintConstant < backgroundView.frame.height/3 {
            trayTopConstraintConstant = 0
        } else if trayTopConstraintConstant < 2*backgroundView.frame.height/3 {
            trayTopConstraintConstant = backgroundView.frame.height/2
        } else {
            trayTopConstraintConstant = backgroundView.frame.height
        }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.homeView.layoutIfNeeded()
            },
            completion: nil
        )
    }

    override func loadView() { view = HomeView() }

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin), name: .wfDidLoginCandidate, object: nil)
    }
    
    @objc func handleLogin() {
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureViews()
        refresh()
    }
    
    func refresh() {
        homeView.refresh()
    }
    
    var isConfigured = false
    func configureViews() {
        adjustNavigationBar()
        guard !isConfigured else { return }
        isConfigured = true
        configureHomeView()
        configureTray()
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
    
    func configureHomeView() {
        homeView.isUserInteractionEnabled = true
        homeView.configureViews()
        homeView.headerView.height = (navigationBar?.frame.height ?? 0) + statusBarHeight
        homeView.headerVerticalOffset = 0
        homeView.layoutSubviews()
    }
    
    func configureTray() {
        trayController = DiscoveryTrayController()
        backgroundView.addSubview(tray)
        tray.anchor(top: nil, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor)
        tray.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
        tray.addGestureRecognizer(pan)
        trayTopConstraintConstant = backgroundView.frame.height/2
        tray.addGestureRecognizer(pan)
    }
    
}
