
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HomeViewController: UIViewController {
    lazy var messageHandler = HSUserMessageHandler(presenter: self)
    weak var coordinator: HomeCoordinator?

    var homeView: HomeView { view as! HomeView }
    var headerView: HeaderView { homeView.headerView }
    var backgroundView: BackgroundView { homeView.backgroundView }
    
    let trayController: DiscoveryTrayController
    
    var tray: DiscoveryTrayView { trayController.tray }
    
    lazy var scrollHijackOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hijackScroll)))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(hijackScroll)))
        return view
    }()
    
    @objc func hijackScroll() {
        trayTopConstraintConstant = 0
        tray.layer.cornerRadius = 0
        tray.layer.shadowRadius = 0
        tray.layer.shadowColor = UIColor.clear.cgColor
        animateTrayToFinalPosition()
        scrollHijackOverlay.removeFromSuperview()
    }
    
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
            homeView.endEditing(true)
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
    
    var isShowingError = false
    @objc func handleErrorNotification(_ notification: Notification) {
        guard let wfError = notification.object as? WorkfinderError else { return }
        guard !isShowingError else {
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                wfError.retryHandler?()
            }
            return
        }
        isShowingError = true
        let alert = UIAlertController(title: "Data isn't loading", message: "Please check your internet connection", preferredStyle: .alert)
        if let retryHandler = wfError.retryHandler {
            alert.addAction(
                UIAlertAction(
                    title: "Retry",
                    style: .default,
                    handler: {_ in
                        self.isShowingError = false
                        retryHandler()
                    }
                )
            )
        }
        present(alert, animated: true, completion: nil)
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
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    @objc func animateTrayToTop() {
        trayTopConstraintConstant = 0
        animateTrayToFinalPosition()
    }
    
    func refresh() {
        homeView.refresh()
        trayController.messageHandler = messageHandler
        DispatchQueue.main.async { [weak self] in
            self?.trayController.loadData()
        }
        
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
    
    init(
        coordinator: HomeCoordinator?,
        rolesService: RolesServiceProtocol,
        typeAheadService: TypeAheadServiceProtocol,
        projectTypesService: ProjectTypesServiceProtocol,
        employmentTypesService: EmploymentTypesServiceProtocol,
        skillsTypeService: SkillAcquiredTypesServiceProtocol,
        searchResultsController: SearchResultsController
    ) {
        self.coordinator = coordinator
        trayController = DiscoveryTrayController(
            coordinator: coordinator,
            rolesService: rolesService,
            typeAheadService: typeAheadService,
            projectTypesService: projectTypesService,
            employmentTypesService: employmentTypesService,
            skillTypesService: skillsTypeService,
            searchResultsController: searchResultsController,
            messageHandler: nil
        )
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleErrorNotification), name: .wfHomeScreenErrorNotification, object: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
        backgroundView.addSubview(tray)
        tray.anchor(top: nil, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor)
        tray.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
        trayTopConstraintConstant = backgroundView.frame.height/2
        tray.addSubview(scrollHijackOverlay)
        scrollHijackOverlay.anchor(top: tray.topAnchor, leading: tray.leadingAnchor, bottom: tray.bottomAnchor, trailing: tray.trailingAnchor)
    }
    
}
