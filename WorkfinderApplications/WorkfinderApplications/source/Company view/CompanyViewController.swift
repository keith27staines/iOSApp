
import UIKit
import WorkfinderCommon
import WorkfinderUI
import MapKit

class CompanyViewController: UIViewController {
    
    lazy var userMessageHandler = UserMessageHandler(presenter: self)
    let presenter: CompanyViewPresenter
    let iconViewRadius = CGFloat(10)
    let iconViewSize = CGSize(width: 96, height: 96)
    
    lazy var iconContainerView: UIView = {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: self.iconViewSize))
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: iconViewRadius).cgPath
        view.addSubview(self.companyIconImageView)
        self.companyIconImageView.fillSuperview()
        return view
    }()
    
    lazy var companyIconImageView: CompanyLogoView = {
        let imageView = CompanyLogoView(widthPoints: 96)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let distanceLabelColor = UIColor.init(white: 0.5, alpha: 1)
    
    lazy var distanceStack: UIStackView = {
        let locationImage = UIImage(named: "location")?.withRenderingMode(.alwaysTemplate)
        let locationIcon = UIImageView(image: locationImage)
        locationIcon.contentMode = .scaleAspectFit
        locationIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true
        locationIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        locationIcon.tintColor = self.distanceLabelColor
        let stack = UIStackView(arrangedSubviews: [locationIcon, self.distanceLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.text = "2.0 km away"
        label.textColor = UIColor.init(white: 0.5, alpha: 1)
        label.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer(target: self, action: #selector(showMap))
        label.addGestureRecognizer(touch)
        return label
    }()
    
    @objc func showMap() {
        if mapOffsetConstant == mapInConstant {
            animateMapOut()
        } else {
            animateMapIn()
        }
    }
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.addSubview(iconContainerView)
        view.addSubview(companyNameLabel)
        view.addSubview(distanceStack)
        iconContainerView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, size: iconViewSize)
        companyNameLabel.anchor(top: nil, leading: companyIconImageView.trailingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        companyNameLabel.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor).isActive = true
        distanceStack.anchor(top: companyNameLabel.bottomAnchor, leading: companyNameLabel.leadingAnchor, bottom: nil, trailing: companyNameLabel.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NameValueCell.self, forCellReuseIdentifier: NameValueCell.reuseIdentifier)
        tableView.register(CompanySummaryTextCell.self, forCellReuseIdentifier: CompanySummaryTextCell.reuseIdentifier)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionFooter")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    var mapTopConstraint: NSLayoutConstraint?
    var mapBottomConstraint: NSLayoutConstraint?
    
    lazy var mapView: CompanyMapView = {
        let mapView = CompanyMapView(
            companyName: self.presenter.companyName ?? "unknown company",
            companyLatLon: self.presenter.companyLocation)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        return mapView
    }()
    
    var mapOutContstant: CGFloat = 2000
    var mapInConstant: CGFloat = 0
    var mapOffsetConstant: CGFloat = 2000 {
        didSet {
            mapTopConstraint?.constant = mapOffsetConstant
            mapBottomConstraint?.constant = mapOffsetConstant
        }
    }
    
    func animateMapIn() {
        mapOffsetConstant = mapInConstant
        mapView.prepareForDisplay()
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 2,
            options: [],
            animations: { [weak self] in
                self?.view.layoutSubviews()
        }, completion: nil)
    }
    
    @objc func animateMapOut() {
        mapOffsetConstant = mapOutContstant
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [UIView.AnimationOptions.curveEaseIn],
            animations: { [weak self] in
                self?.view.layoutSubviews()
        })
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Company"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = WorkfinderColors.white
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateMapOut)))
        let guide = view.safeAreaLayoutGuide
        headerView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        tableView.anchor(top: headerView.bottomAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        mapTopConstraint = mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        mapBottomConstraint = mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        mapTopConstraint?.isActive = true
        mapBottomConstraint?.isActive = true
        mapInConstant = 100.0
        mapOutContstant = view.frame.height
        mapOffsetConstant = view.frame.height
    }
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(view: self)
        loadData()
    }
    
    func loadData() {
        refreshFromPresenter()
        userMessageHandler.showLoadingOverlay(self.view)
        presenter.loadData { [weak self] (optionalError) in
            guard let self = self else { return }
            self.userMessageHandler.hideLoadingOverlay()
            self.userMessageHandler.displayOptionalErrorIfNotNil(optionalError, retryHandler: self.loadData)
            self.refreshFromPresenter()
            self.configureMapView()
        }
    }
    
    func refreshFromPresenter() {
        companyNameLabel.text = presenter.companyName
        companyIconImageView.load(
            companyName: presenter.companyName ?? "?",
            urlString: presenter.logoUrlString, completion: nil)
        distanceLabel.text = presenter.distanceFromUserToCompany
        self.tableView.reloadData()
    }
    
    init(presenter: CompanyViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension CompanyViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return presenter.cellForTable(tableView, indexPath: indexPath)
    }
}

extension CompanyViewController: UITableViewDelegate {
    
}

extension CompanyViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView()
        if annotation is F4SCompanyAnnotation {
            view.canShowCallout = true
            view.image = #imageLiteral(resourceName: "markerFavouriteIcon")
            return view
        }
        return nil
    }
}


