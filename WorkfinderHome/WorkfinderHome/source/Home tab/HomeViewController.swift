
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HomeViewController: UIViewController {
    lazy var messageHandler = HSUserMessageHandler(presenter: self)
    weak var coordinator: HomeCoordinator?

    var homeView: HomeView { view as! HomeView }
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
    
    var hijacked = false
    @objc func hijackScroll() {
        guard hijacked == false else { return }
        hijacked = true
        scrollHijackOverlay.removeFromSuperview()
        trayTopConstraintConstant = 0
        animateTrayToFinalPosition()
        navigationItem.title = "Discover"
    }
    
    lazy var trayTopConstraint: NSLayoutConstraint = {
        let constraint = tray.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        constraint.isActive = true
        return constraint
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func configureNavigationBar() {
        styleNavigationController()
    }
    
    var trayTopConstraintConstant: CGFloat = 0 {
        didSet {
            let guide = homeView.backgroundView.safeAreaLayoutGuide
            trayTopConstraintConstant = max(guide.layoutFrame.minY + 0, trayTopConstraintConstant)
            trayTopConstraintConstant = min(guide.layoutFrame.maxY - 40, trayTopConstraintConstant)
            trayTopConstraint.constant = trayTopConstraintConstant
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
                let tray = self.tray
                tray.layer.cornerRadius = 0
                tray.layer.shadowRadius = 0
                tray.layer.shadowColor = UIColor.clear.cgColor
                self.homeView.layoutIfNeeded()
            },
            completion: {_ in
                if self.trayTopConstraintConstant == 0 {}
            }
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchIsActive), name: .wfHomeScreenSearchIsActive, object: nil)
        refresh()
        isSearchActive = true
    }
    
    @objc func handleSearchIsActive(notification: Notification) {
        isSearchActive = (notification.userInfo?["isSearchActive"] as? Bool) ?? false
    }
    
    var isSearchActive: Bool {
        didSet {
            updateNavigationBar()
        }
    }
    
    func updateNavigationBar() {
        navigationItem.title = isSearchActive ? "" : "Discover"
        navigationController?.setNavigationBarHidden(isSearchActive, animated: true)
    }
    
    @objc func handleLogin() {
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
        updateNavigationBar()
    }
    
    @objc func animateTrayToTop() {
        trayTopConstraintConstant = 0
        animateTrayToFinalPosition()
    }
    
    func refresh() {
        homeView.refresh()
        trayController.messageHandler = messageHandler
        DispatchQueue.main.async { [weak self] in
            self?.trayController.loadFirstPage()
        }
    }
    
    var isConfigured = false
    func configureViews() {
        guard !isConfigured else { return }
        configureNavigationBar()
        isConfigured = true
        configureHomeView()
        configureTray()
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
        isSearchActive = false
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleErrorNotification), name: .wfHomeScreenErrorNotification, object: nil)
        backgroundView.upArrowTapped = { self.hijackScroll() }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

extension HomeViewController {
    var navigationBar: UINavigationBar? { navigationController?.navigationBar }
    
    func configureHomeView() {
        homeView.isUserInteractionEnabled = true
        homeView.configureViews()
        homeView.layoutSubviews()
    }
    
    func configureTray() {
        backgroundView.addSubview(tray)
        tray.anchor(top: nil, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor)
        tray.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
        trayTopConstraintConstant = backgroundView.frame.height/2 - 56
        tray.addSubview(scrollHijackOverlay)
        scrollHijackOverlay.anchor(top: tray.topAnchor, leading: tray.leadingAnchor, bottom: tray.bottomAnchor, trailing: tray.trailingAnchor)
    }
    
}
