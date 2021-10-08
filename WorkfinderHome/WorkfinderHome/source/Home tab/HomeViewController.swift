
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
        backgroundView.backgroundColor = UIColor.white
    }
    
    lazy var trayTopConstraint: NSLayoutConstraint = {
        let constraint = tray.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        constraint.isActive = true
        return constraint
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isSearchActive ? .default : .lightContent
    }

    func configureNavigationBar() {
        styleNavigationController()
        updateNavigationBar()
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
    
    private lazy var navigationBarActivityItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(customView: navigationBarActivityIndicator)
        return barButton
    }()
    
    private lazy var navigationBarActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        indicator.color = WFColorPalette.readingGreen
        return indicator
    }()
    
    private lazy var navigationBarRefreshButton: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }()
    
    private func showLoadingIndicators() {
        navigationItem.setRightBarButton(navigationBarActivityItem, animated: true)
        navigationBarActivityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicators() {
        navigationBarActivityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem = navigationBarRefreshButton
    }
    
    private var isTrayExpanded: Bool = false {
        didSet {
            updateNavigationBar()
        }
    }
    
    private func animateTrayToFinalPosition() {
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
            completion: { [weak self] _ in
                if self?.trayTopConstraintConstant == 0 {}
                self?.isTrayExpanded = true
            }
        )
    }
    
    private var isShowingError = false
    @objc private func handleErrorNotification(_ notification: Notification) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }
    
    @objc private func handleSearchIsActive(notification: Notification) {
        isSearchActive = (notification.userInfo?["isSearchActive"] as? Bool) ?? false
    }
    
    var isSearchActive: Bool = false {
        didSet {
            updateNavigationBar()
        }
    }
    
    private func updateNavigationBar() {
        switch isTrayExpanded {
        case true: updateNavigationBarWithTrayExpanded()
        case false: updateNavigationBarWithTrayNotExpanded()
        }
    }
        
    private func updateNavigationBarWithTrayExpanded() {
        navigationItem.title = "Discover"
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.barTintColor = self.isSearchActive ? UIColor.white : WorkfinderColors.white
        self.navigationController?.setNavigationBarHidden(self.isSearchActive, animated: true)
        navigationBar.scrollEdgeAppearance?.backgroundColor = WFColorPalette.white
        navigationBar.scrollEdgeAppearance?.shadowColor = WFColorPalette.border
        navigationBar.shadowImage = nil
        navigationItem.rightBarButtonItem = navigationBarRefreshButton
    }
    
    private func updateNavigationBarWithTrayNotExpanded() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationItem.title = ""
        navigationBar.barTintColor = WFColorPalette.readingGreen
        self.navigationItem.title = ""
        navigationBar.shadowImage = UIImage()
        navigationBar.alpha = 1
        navigationBar.scrollEdgeAppearance?.shadowColor = UIColor.clear
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.compact)
        navigationBar.scrollEdgeAppearance?.backgroundColor = WFColorPalette.readingGreen
    }
    
    @objc func handleLogin() {
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        configureViews()
    }
    
    @objc func animateTrayToTop() {
        trayTopConstraintConstant = 0
        animateTrayToFinalPosition()
    }
    
    @objc func refresh() {
        homeView.refresh()
        trayController.messageHandler = messageHandler
        showLoadingIndicators()
        DispatchQueue.main.async { [weak self] in
            self?.trayController.loadData() {
                self?.hideLoadingIndicators()
            }
        }
    }
    
    var isConfigured = false
    func configureViews() {
        guard !isConfigured else { return }
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
        trayTopConstraintConstant = backgroundView.frame.height/2 - 25
        tray.addSubview(scrollHijackOverlay)
        scrollHijackOverlay.anchor(top: tray.topAnchor, leading: tray.leadingAnchor, bottom: tray.bottomAnchor, trailing: tray.trailingAnchor)
    }
    
}
