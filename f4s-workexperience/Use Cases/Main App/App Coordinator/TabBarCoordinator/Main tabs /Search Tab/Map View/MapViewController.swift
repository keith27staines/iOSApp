//
//  MapViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 09/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import GoogleMaps
import Reachability
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI
import WorkfinderOnboardingUseCase

enum CamerWillMoveAction {
    case explodeCluster(GMUCluster)
    case other
    case none
}

class MapViewController: UIViewController {
    
    let screenName = ScreenName.map
    weak var coordinator: SearchCoordinator?
    
    let peopleDataSource: SearchDataSourcing = PeopleSearchDataSource()
    let companyDataSource: SearchDataSourcing = CompanySearchDataSource()
    let placesDataSource: SearchDataSourcing = PlacesSearchDataSource()
    let userMessageHandler = UserMessageHandler()
    var log: F4SAnalyticsAndDebugging!
    
    lazy var searchView: SearchView = {
        let sideMargin: CGFloat = 20
        let searchView = SearchView(expandedWidth: view.bounds.width - 2*sideMargin, frame: CGRect.zero)
        searchView.log = self.log
        searchView.delegate = self
        searchView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(searchView)
        searchView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 40, left: sideMargin, bottom: 0, right: 0))
        let bottomConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            bottomConstraint = searchView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        } else {
            bottomConstraint = searchView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -80)
        }
        bottomConstraint.priority = .required
        bottomConstraint.isActive = true
        return searchView
    }()
    
    lazy var clusterColor: UIColor = {
        return skin?.primaryButtonSkin.backgroundColor.uiColor ?? UIColor.black
    }()
    
    @IBOutlet weak var logoStack: UIStackView!
    @IBOutlet weak var partnerLogoImageView: UIImageView!
    @IBOutlet weak var workfinderLogoImageView: UIImageView!
    
    var cameraWillMoveAction: CamerWillMoveAction = .none {
        didSet {
            switch cameraWillMoveAction {
            case .none:
                oldVisibleMapBounds = nil
            default:
                oldVisibleMapBounds = visibleMapBounds
            }
        }
    }
    var oldVisibleMapBounds : GMSCoordinateBounds? = nil
    
    static let hideAllPopupsNotificationName = Notification.Name(rawValue:"hideAllPopups")
    
    /// Displays the map
    @IBOutlet var mapView: GMSMapView!
    
    var popupAnimator = PopupAnimator()
    var companyListPopupViewController: PopupCompanyListViewController?
    
    var mapEdgeInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60)
    }
    
    /// Container view for the search text box and closely associated controls
    @IBOutlet weak var myLocationButton: UIButton!
    
    /// Container view for the filter button and associated controls
    @IBOutlet weak var refineLabelContainerView: UIView!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var refineSearchLabel: UILabel!
    
    /// Manages clustering of the pins on the map
    fileprivate var clusterManager: GMUClusterManager!
    
    /// Manages location updates from the device
    fileprivate var locationManager: CLLocationManager?
    
    /// Last authorization status reported by `locationManager`
    fileprivate var lastAuthorizationStatus: CLAuthorizationStatus?
    
    /// When auto-zooming out from a point location, zoom out until this number of companies are displayed (target only, exact number might be different)
    let targetCompaniesCountForAutoZoom: Int = 30
    
    /// The default location if the user hasn't allowed myLocation and hasn't entered a location yet (roughly the centroid of GB)
    static let centerUkCoord = CLLocationCoordinate2DMake(52.533505, -1.445217)
    
    /// The minimum zoom level 
    static let zoomMinimum: Float = 6.0
    static let zoomMaximum: Float = 15.0
    
    var backgroundView = UIView()
    var shouldRequestAuthorization: Bool = false
    var pressedPinOrCluster: UIView?
    var allowLocationUpdate: Bool = false
    
    /// User locations are entered manually through the search box
    var userLocation: CLLocation? {
        didSet {
            if let location = userLocation?.coordinate {
                self.moveAndZoomCamera(to: location)
            }
        }
    }
    
    ///Bounds representing the visible portion of the map
    var visibleMapBounds: GMSCoordinateBounds? {
        let visibleRegion = mapView.projection.visibleRegion()
        return GMSCoordinateBounds(region: visibleRegion)
    }
    
    /// Map model of all companies (unfiltered by interest)
    var unfilteredMapModel: MapModel?
    
    /// Map model for companies satisfying the interest filters
    var filteredMapModel: MapModel?
    
    var interestsRepository: F4SInterestsRepositoryProtocol!
    
    /// Used to determine whether there is internet connectivity
    var reachability: Reachability?
    
    /// The set of all pins currently added to the map
    var emplacedCompanyPins: F4SCompanyPinSet = []
    
    /// The list of currently favourited companies
    var favouriteList: [Shortlist] = [] {
        didSet {
            let companyUuids = favouriteList.map { (shortlist) -> F4SUUID in
                return shortlist.companyUuid
            }
            var newFavourites = F4SCompanyPinSet()
            for uuid in companyUuids {
                if let pin = unfilteredMapModel?.allPinsByCompanyUuid[uuid] {
                    newFavourites.insert(pin)
                }
            }
            favouriteSet = newFavourites
        }
    }
    
    /// The favourites last known to this view
    var previousFavouriteSet: F4SCompanyPinSet?
    
    /// Updated set of favourites
    var favouriteSet: Set<F4SCompanyPin> = Set<F4SCompanyPin>() {
        didSet {
            self.previousFavouriteSet = favouriteSet
        }
    }
    
    /// The company currently selected by the user (if any)
    var selectedCompany: Company?
    
    var infoWindowView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = searchView
        if let dbManager = (UIApplication.shared.delegate as? AppDelegate)?.databaseDownloadManager {
            dbManager.registerObserver(self)
        }
        
        adjustAppeareance()
        setupMap()
        setupReachability(nil, useClosures: true)
        startNotifier()
        if !(UIApplication.shared.delegate as! AppDelegate).databaseDownloadManager!.isLocalDatabaseAvailable() {
            userMessageHandler.showLoadingOverlay(self.view)
        } else {
            reloadMap()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.screen(screenName)
        adjustNavigationBar()
        displayRefineSearchLabelAnimated()
        favouriteList = ShortlistDBOperations.sharedInstance.getShortlist()
    }
    
    var hasMovedToBestPosition: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyBranding()
        self.becomeFirstResponder()
        if !hasMovedToBestPosition {
            moveCameraToBestPosition()
            hasMovedToBestPosition = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let dbManager = (UIApplication.shared.delegate as? AppDelegate)?.databaseDownloadManager {
            dbManager.removeObserver(self)
        }
        super.viewWillDisappear(animated)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func companiesFromMarker(_ marker: GMSMarker) -> [Company] {
        guard let mapModel = filteredMapModel else { return [Company]() }
        let companySet = mapModel.pinsNear(marker.position, side: 10.0)
        let companyPins = [F4SCompanyPin](companySet)
        let companies = companyPins.map { pin -> Company in
            return companyFromPin(pin: pin)!
        }
        return companies
    }
    
    func presentCompaniesPopup(for cluster: GMUCluster) {
        let companies = companiesFromCluster(cluster)
        let origin = mapView.projection.point(for: cluster.position)
        presentCompaniesPopup(for: companies, origin: origin)
    }

    func presentCompaniesPopup(for companies: [Company], origin: CGPoint) {
        let originatingRect = CGRect(x: origin.x-20, y: origin.y-20, width: 40, height: 40)
        if pressedPinOrCluster?.superview == nil {
            pressedPinOrCluster = UIView(frame: originatingRect)
        } else {
            pressedPinOrCluster?.frame = originatingRect
        }
        pressedPinOrCluster?.backgroundColor = UIColor.clear
        mapView.addSubview(pressedPinOrCluster!)
        
        let vc = UIStoryboard(name: "PopupCompanyList", bundle: nil).instantiateViewController(withIdentifier: "PopupListViewController") as! PopupCompanyListViewController
        vc.didSelectCompany = { [weak self] company in
            self?.coordinator?.showDetail(company: company, originScreen: vc.screenName)
        }
        vc.setCompanies(companies)
        vc.log = log
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    deinit {
        stopNotifier()
    }
    
    func applyBranding() {
        
    }
}

// MARK:- Conform to InterestsViewControllerDelegate
extension MapViewController : InterestsViewControllerDelegate {
    func interestsViewController(_ vc: InterestsViewController, didChangeSelectedInterests interestFilterSet: F4SInterestSet) {
        guard let unfilteredMapModel = self.unfilteredMapModel else { return }
        createFilteredMapModel(
            unfilteredModel: unfilteredMapModel,
            interestFilterSet: interestFilterSet) { [weak self] (filteredModel) in
                self?.filteredMapModel = filteredModel
                self?.reloadMapFromModel(mapModel: filteredModel, completed: {
            })
        }
    }
}

// MARK:- Manage pins on map
extension MapViewController {
    
    /// Adds the specified pin to the map and its associated data structures:
    /// 1. clusterManager
    /// 2. emplacedCompanyPins
    fileprivate func addPinToMap(pin: F4SCompanyPin) {
        if !emplacedCompanyPins.contains(pin) {
            pin.isFavourite = favouriteSet.contains(pin)
            clusterManager.add(pin)
            emplacedCompanyPins.insert(pin)
        }
    }
}

// MARK: - UI Setup
extension MapViewController {
    
    fileprivate func adjustAppeareance() {
        setupButtons()
        setupLabels()
        self.view.layoutIfNeeded()
    }
    
    fileprivate func setupButtons() {
        filtersButton.layer.cornerRadius = filtersButton.bounds.height / 2
        filtersButton.layer.masksToBounds = true
        filtersButton.setBackgroundColor(color: splashColor, forUIControlState: .normal)
        filtersButton.setImage(UIImage(named: "filtersIcon"), for: .normal)
        filtersButton.setImage(UIImage(named: "filtersIcon"), for: .highlighted)
        myLocationButton.tintColor = splashColor
    }
    
    fileprivate func setupLabels() {
        let refineStr = NSLocalizedString("Refine your search!", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.tailIndent = 163
        
        self.refineSearchLabel.attributedText = NSAttributedString(
            string: refineStr,
            attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraph])
    }
    
    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.black)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    func setupInfoWindow(company: Company) -> UIView {
        guard let infoWindow = Bundle.main.loadNibNamed("InfoWindowView", owner: self, options: nil)?.first as? InfoWindowView else {
            return UIView()
        }
        
        infoWindow.companyNameLabel.attributedText = NSAttributedString(
            string: company.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        infoWindow.industryNameLabel.attributedText = NSAttributedString(
            string: company.industry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Style.smallerMediumTextSize, weight: UIFont.Weight.light), NSAttributedString.Key.foregroundColor: UIColor.black])
        infoWindow.logoImageView.load(urlString: company.logoUrl, defaultImage: UIImage(named: "DefaultLogo"))
        
        if company.rating < 0.5 {
            infoWindow.ratingStackView.removeFromSuperview()
        } else {
            setInfoWindowStars(infoWindow: infoWindow, unroundedRating: company.rating)
            
            infoWindow.ratingLabel.attributedText = NSAttributedString(
                string: String(format: "%.1f", company.rating),
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Style.biggerVerySmallTextSize, weight: UIFont.Weight.semibold),
                             NSAttributedString.Key.foregroundColor: UIColor.black])
        }
        
        let height = infoWindow.backgroundView.bounds.height
        infoWindow.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 335,
                                  height: height + infoWindow.triangleView.bounds.height)
        infoWindow.backgroundView.layer.shadowColor = UIColor.black.cgColor
        infoWindow.backgroundView.layer.shadowRadius = 1
        infoWindow.backgroundView.layer.shadowOpacity = 0.1
        infoWindow.backgroundView.layer.shadowOffset = CGSize(width: 2, height: -2)
        infoWindow.backgroundView.layer.cornerRadius = 10
        
        return infoWindow
    }
    
    func setInfoWindowStars(infoWindow: InfoWindowView, unroundedRating: Double) {
        let roundedRating = unroundedRating.round()
        if roundedRating == 0.5 {
            infoWindow.firstStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 1 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 1.5 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 2 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 2.5 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.thirdStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 3 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.thirdStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 3.5 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.thirdStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.fourthStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 4 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.thirdStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.fourthStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 4.5 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.thirdStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.fourthStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.fifthStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 5 {
            infoWindow.firstStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.secondStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.thirdStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.fourthStarImageView.image = UIImage(named: "FilledStar")
            infoWindow.fifthStarImageView.image = UIImage(named: "FilledStar")
        }
    }
    
    enum transitionType {
        case slideIn
        case slideOut
    }
    
    func setupSlideInAnimation(_ transitionType: transitionType, completionDelegate: CAAnimationDelegate? = nil) {
        switch transitionType {
        case .slideIn:
            let slideInTransition = CATransition()
            if let delegate: CAAnimationDelegate = completionDelegate {
                slideInTransition.delegate = delegate
            }
            slideInTransition.type = CATransitionType.push
            slideInTransition.subtype = CATransitionSubtype.fromRight
            slideInTransition.duration = 1
            slideInTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            slideInTransition.fillMode = CAMediaTimingFillMode.removed
            
            refineSearchLabel.layer.add(slideInTransition, forKey: "slideInFromRight")
        case .slideOut:
            let slideOutTransition = CATransition()
            if let delegate: CAAnimationDelegate = completionDelegate {
                slideOutTransition.delegate = delegate
            }
            slideOutTransition.type = CATransitionType.push
            slideOutTransition.subtype = CATransitionSubtype.fromLeft
            slideOutTransition.duration = 1
            slideOutTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            slideOutTransition.fillMode = CAMediaTimingFillMode.removed
            // slideOutTransition.delegate =
            refineSearchLabel.layer.add(slideOutTransition, forKey: "slideOutFromLeft")
        }
    }
    
    func displayRefineSearchLabelAnimated() {
        let interestsCount = interestsRepository.loadInterestsSet().count
        if self.refineSearchLabel.isHidden && interestsCount == 0 {
            self.refineLabelContainerView.isHidden = false
            self.setupSlideInAnimation(transitionType.slideIn, completionDelegate: self)
            self.refineSearchLabel.isHidden = false
        }
    }
    
    func hideRefineSearchLabelAnimated() {
        if !self.refineSearchLabel.isHidden {
            self.setupSlideInAnimation(transitionType.slideOut, completionDelegate: self)
            self.refineSearchLabel.isHidden = true
        }
    }
}

// MARK: - Map Setup + Location Methods
extension MapViewController {
    
    fileprivate func setupMap() {
        mapView.delegate = self
        
        // cluster algorithm setup
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let iconGenerator = self.iconGeneratorWithImages()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        
        locationManager = makeLocationManager()
        if shouldRequestAuthorization {
            locationManager?.requestWhenInUseAuthorization()
            allowLocationUpdate = true
        }
        
        mapView.settings.myLocationButton = false
        mapView.setMinZoom(6.0, maxZoom: 16.0)
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
    }
    
    fileprivate func iconGeneratorWithImages() -> GMUClusterIconGenerator {
        return CustomClusterIconGenerator(color: clusterColor)
    }
    
    fileprivate func makeLocationManager() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.delegate = self
        return manager
    }
}

// MARK:- Camera position management
extension MapViewController  {
    /// Moves the camera to its last idle position if available, else to my location or user selected location with dynamic zoom to ensure a reasonable number of company pins on map, or failing all of that, show the entire UK
    func moveCameraToBestPosition() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let target = strongSelf.mapView.myLocation ?? strongSelf.userLocation {
                strongSelf.moveAndZoomCamera(to: target.coordinate)
            } else {
                strongSelf.moveCamera(to: MapViewController.centerUkCoord, zoom: MapViewController.zoomMinimum)
            }
        }
    }
    
    /// Moves the camera to the specified location and sets the zoom to the specified value
    func moveCamera(to location: CLLocationCoordinate2D, zoom: Float) {
        let cameraPosition = GMSCameraPosition(target: location,
                                               zoom: zoom,
                                               bearing: 0,
                                               viewingAngle: 0)
        mapView.animate(to: cameraPosition)
        
    }
    
    /// Moves and zooms the camera to display a reasonable number of pins around the specified location.
    func moveAndZoomCamera(to location: CLLocationCoordinate2D) {
        guard let mapModel = unfilteredMapModel else {
            // Without a model all we can do is move the camera to the specified location
            DispatchQueue.main.async { [weak self] in
                self?.mapView.animate(toLocation: location)
            }
            return
        }
        // Get the target number of company pins near the specified location and zoom in on bounds that enclose them
        mapModel.getCompanyPins(
            target : targetCompaniesCountForAutoZoom,
            near: location) { [weak self] pins in
                self?.unfilteredMapModel = mapModel
                self?.moveCamera(to: location, zoomToShow: pins)
        }
    }
    
    /// Moves the camera to the specified location and zooms out enough to show an area of the map that includes the locations of all the pins in the specified set
    func moveCamera(to location: CLLocationCoordinate2D, zoomToShow pins: F4SCompanyPinSet) {
        var bounds = GMSCoordinateBounds(coordinate: location, coordinate: location)
        for pin in pins {
            bounds = bounds.includingCoordinate(pin.position)
        }
        DispatchQueue.main.async { [weak self] in
            guard let mapView = self?.mapView, let mapEdgeInsets = self?.mapEdgeInsets else {
                return
            }
            mapView.animate(with: GMSCameraUpdate.fit(bounds, with: mapEdgeInsets))
        }
    }
    
    // Moves the camera to show the specified bounds
    func moveCamera(toShow bounds: GMSCoordinateBounds) {
        DispatchQueue.main.async { [weak self] in
            guard let mapView = self?.mapView else {
                return
            }
            mapView.animate(with: GMSCameraUpdate.fit(bounds))
        }
    }
    
    /// Returns the bounds of the visible portion of the map
    func getVisibleRegion() -> GMSVisibleRegion {
        let topLeftPoint = CGPoint(x: mapView.bounds.minX, y: mapView.bounds.minY)
        let bottomRightPoint = CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.maxY)
        let topRightPoint = CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.minY)
        let bottomLeftPoint = CGPoint(x: mapView.bounds.minX, y: mapView.bounds.maxY)

        let topLeftLocation = mapView.projection.coordinate(for: topLeftPoint)
        let bottomRightLocation = mapView.projection.coordinate(for: bottomRightPoint)
        let topRightLocation = mapView.projection.coordinate(for: topRightPoint)
        let bottomLeftLocation = mapView.projection.coordinate(for: bottomLeftPoint)

        let visibleRegionForPoints = GMSVisibleRegion(nearLeft: bottomLeftLocation, nearRight: bottomRightLocation, farLeft: topLeftLocation, farRight: topRightLocation)

        return visibleRegionForPoints
    }
}

// MARK: - CAAnimationDelegate
extension MapViewController: CAAnimationDelegate {
    
    func animationDidStop(_: CAAnimation, finished flag: Bool) {
        if flag && self.refineSearchLabel.isHidden {
            self.refineLabelContainerView.isHidden = true
        }
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.selectedCompany = nil
        self.mapView.selectedMarker = nil
    }
    
    func mapView(_: GMSMapView, willMove gesture: Bool) {
        if gesture {
            hideRefineSearchLabelAnimated()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let origin = mapView.projection.point(for: marker.position)
        let companies = companiesFromMarker(marker)
        if companies.count > 1 {
            presentCompaniesPopup(for: companies, origin: origin)
            return true
        } else {
            self.selectedCompany = companyFromMarker(marker: marker)
            self.mapView.selectedMarker = marker
            var point: CGPoint = mapView.projection.point(for: marker.position)
            point.y -= 50
            let camera: GMSCameraUpdate = GMSCameraUpdate.setTarget(mapView.projection.coordinate(for: point))
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.tracksInfoWindowChanges = true
            mapView.animate(with: camera)
            return true
        }
    }
    
    func mapView(_: GMSMapView, idleAt pos: GMSCameraPosition) {
        switch cameraWillMoveAction {
        case .explodeCluster(let cluster):
            if oldVisibleMapBounds == visibleMapBounds {
                presentCompaniesPopup(for: cluster)
            }
        default:
            break
        }
        cameraWillMoveAction = .none
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let selectedCompany = self.selectedCompany else {
            return nil
        }
        guard let company = companyFromMarker(marker: marker) else {
            return nil
        }
        guard company.uuid == selectedCompany.uuid else {
            return nil
        }
        self.infoWindowView = setupInfoWindow(company: company)
        return infoWindowView
    }
    
    func mapView(_: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let company = companyFromMarker(marker: marker) else {
            return
        }
        coordinator?.showDetail(company: company, originScreen: ScreenName.companyPin)
    }
    
    func mapView(_: GMSMapView, didCloseInfoWindowOf _: GMSMarker) {

    }

}

// MARK: - GMUClusterManager Delegate
extension MapViewController: GMUClusterManagerDelegate {
    
    func clusterManager(_: GMUClusterManager, didTap cluster: GMUCluster) {
        guard let explodedBounds = boundsForExplodedClusterContent(cluster) else {
            let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
            let update = GMSCameraUpdate.setCamera(newCamera)
            mapView.animate(with: update)
            return
        }
        if shouldExplodeCluster(cluster) {
            cameraWillMoveAction = .explodeCluster(cluster)
            moveCamera(toShow: explodedBounds)
        } else {
            presentCompaniesPopup(for: cluster)
        }
    }
    
    func canZoomIn() -> Bool {
        return mapView.camera.zoom < mapView.maxZoom
    }
    
    func canZoomOut() -> Bool {
        return mapView.camera.zoom > mapView.minZoom
    }
    
    func shouldExplodeCluster(_ cluster: GMUCluster) -> Bool {
        if !canZoomIn() {
            return false
        }
        guard let explodedBounds = boundsForExplodedClusterContent(cluster), let _ = self.visibleMapBounds else {
            return false
        }
        if cluster.items.count < 11 || explodedBounds.diagonalDistance() < 200 {
            return false
        }
        return true
    }
}

// MARK:- Clusters helpers
extension MapViewController {
    
    func boundsForExplodedClusterContent(_ cluster: GMUCluster) -> GMSCoordinateBounds? {
        guard let firstPosition = cluster.items.first?.position else {
            return nil
        }
        var bounds = GMSCoordinateBounds(coordinate: firstPosition, coordinate: firstPosition)
        for item in cluster.items {
            bounds = bounds.includingCoordinate(item.position)
        }
        return bounds
    }
}

// MARK: - CLLocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
            
        case .authorizedWhenInUse:
            locationManager!.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            allowLocationUpdate = true
            
        case .denied:
            mapView.isMyLocationEnabled = false
            
        case .authorizedAlways:
            locationManager!.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            allowLocationUpdate = true
            
        case .restricted:
            mapView.isMyLocationEnabled = false
            
        case .notDetermined:
            break
        @unknown default:
            assert(true, "unexpcted authorization status")
        }
        self.lastAuthorizationStatus = status
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager!.stopUpdatingLocation()
        if allowLocationUpdate {
            allowLocationUpdate = false
            userLocation = location
            moveCameraToBestPosition()
            companyDataSource.userLocation = userLocation?.coordinate
        }
    }
}

// MARK: - User interaction
extension MapViewController {
    
    @IBAction func myLocationButtonTouched(_: UIButton) {
        if let location = mapView.myLocation?.coordinate {
            moveAndZoomCamera(to: location)
        } else {
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
                userMessageHandler.presentEnableLocationInfo(parentCtrl: self)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager?.requestWhenInUseAuthorization()
            }
        }
    }
    
    @IBAction func filtersButtonTouched(_: UIButton) {
        hideRefineSearchLabelAnimated()
        coordinator?.filtersButtonWasTapped()
    }
}

// MARK: - Reachability Setup
extension MapViewController {
    
    func setupReachability(_: String?, useClosures _: Bool) {
        let reachability = Reachability()
        self.reachability = reachability
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: nil)
        reachability = nil
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.isReachableByAnyMeans {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let dbManager = appDelegate.databaseDownloadManager {
                if !dbManager.isLocalDatabaseAvailable() {
                    dbManager.start()
                    userMessageHandler.showLoadingOverlay(view)
                }
            }
        } else {
            if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) == nil {
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else { return }
                    this.userMessageHandler.hideLoadingOverlay()
                    this.userMessageHandler.displayAlertFor("No Internet Connection.", parentCtrl: this)
                }
            }
        }
    }
}

// MARK:- helpers
extension MapViewController {
    
    /// Returns the companies corresponding to the specified cluster
    func companiesFromCluster(_ cluster: GMUCluster) -> [Company] {
        let companyPins = cluster.items as! [F4SCompanyPin]
        var companies = [Company]()
        for pin in companyPins {
            if let company = companyFromPin(pin: pin) {
                companies.append(company)
            }
        }
        return companies
    }
    
    /// Returns the Company corresponding to the specified marker
    func companyFromMarker(marker: GMSMarker) -> Company? {
        guard let pin = marker.userData as? F4SCompanyPin else {
            return nil
        }
        return companyFromPin(pin: pin)
    }
    
    /// Returns the Company corresponding to the specified pin
    func companyFromPin(pin: F4SCompanyPin) -> Company? {
        return DatabaseOperations.sharedInstance.companyWithId(pin.companyId)
    }
    
    /// Sets the userLocation by transforming a place id (or the address string if the place is not provided, or does not correspond to a google places id) into a location
    func setUserLocation(from address: String, placeId: String?) {
        let coordinates = address.components(separatedBy: ",")
        let lat = Double(coordinates[0])
        if coordinates.count < 3 && lat != nil {
            if let lng = Double(coordinates[1]) {
                self.userLocation = CLLocation(latitude: lat!, longitude: lng)
            }
        } else {
            LocationHelper.sharedInstance.googleGeocodeAddressString(address, placeId) { [weak self] coordinates in
                guard let this = self else { return }
                switch coordinates {
                case .value(let coordinates):
                    this.userLocation = CLLocation(latitude: coordinates.value.latitude, longitude: coordinates.value.longitude)
                case .error(let err):
                    if err == "NoConnectivity" {
                        let title = NSLocalizedString("No data connectivity", comment: "")
                        let errorMsg = NSLocalizedString("You appear to be offline at the moment. Please try again later when you have a working internet connection.",
                                                         comment: "")
                        this.userMessageHandler.displayWithTitle(title, errorMsg, parentCtrl: this)
                    } else {
                        let title = NSLocalizedString("Location Not Found", comment: "")
                        let errorMsg = NSLocalizedString("We cannot find the location you entered. Please try again", comment: "")
                        this.userMessageHandler.displayWithTitle(title, errorMsg, parentCtrl: this)
                    }
                }
            }
        }
        
    }
}

extension MapViewController {
    /// Asynchronously clears the map and associated data structures including:
    /// 1. mapView
    /// 2. emplacedCompanyPins
    /// 3. clusterManager
    ///
    /// - parameter completed: Calls back when the map and its datastructures are cleared
    func clearMap(completed: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mapView.clear()
            strongSelf.emplacedCompanyPins.removeAll()
            strongSelf.clusterManager.clearItems()
            completed()
        }
    }
    
    /// Asynchronously creates a filtered map from a less filtered one
    ///
    /// - parameter unfilteredModel: The starting MapModel whose content is to be filtered into a new MapModel
    /// - parameter interestFilterSet: The set of interests to filter companies by. A company must have at least one interest in the interestFilterSet to qualify
    /// - parameter completed: Calls back with the filtered MapModel
    func createFilteredMapModel(unfilteredModel: MapModel,
                                interestFilterSet: F4SInterestSet,
                                completed: @escaping (MapModel) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            let filteredModel = MapModel(allCompanyPinsSet: unfilteredModel.allCompanyPins,
                                         allInterests: unfilteredModel.interestsModel.allInterests,
                                         filtereredBy: interestFilterSet,
                                         clusterColor: strongSelf.clusterColor)
            completed(filteredModel)
        }
    }
    
    /// Asynchronously creates an unfiltered map model by reading directly from the databas
    ///
    /// - parameter completion: Calls back with the newly created MapModel
    func createUnfilteredMapModelFromDatabase(completion: @escaping (MapModel) -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            let dbOps = DatabaseOperations.sharedInstance
            dbOps.getAllCompanies(completed: { companies in
                dbOps.getAllInterests(completed: { (interests) in
                    let mapModel = MapModel(
                        allCompanies: companies,
                        allInterests:interests,
                        selectedInterests: nil,
                        clusterColor: strongSelf.clusterColor)
                    DispatchQueue.main.async {
                        completion(mapModel)
                    }
                })
            })
        }
    }

    /// Asynchronously reloads the map from the specified mapmodel
    ///
    /// - parameter completed: Calls back when the reload is complete
    func reloadMapFromModel(mapModel: MapModel, completed: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.clearMap() { [weak self] in
                guard let strongSelf = self else { return }
                for pin in mapModel.filteredCompanyPinSet {
                    strongSelf.addPinToMap(pin: pin)
                }
                completed()
            }
        }
    }
    
    func reloadMap() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.userMessageHandler.showLoadingOverlay(strongSelf.view)
            strongSelf.userMessageHandler.updateOverlayCaption("Updating map...")
            DatabaseOperations.sharedInstance.promoteStagedDatabase()
            strongSelf.reloadMapFromDatabase {
                DispatchQueue.main.async {
                    strongSelf.moveCameraToBestPosition()
                    strongSelf.userMessageHandler.hideLoadingOverlay()
                }
            }
        }
    }
    
    /// Asynchronously reloads the map from datastructures read from the database
    ///
    /// - parameter completion: Call back when the reload is complete
    func reloadMapFromDatabase(completion: @escaping () -> Void ) {
        self.favouriteList = ShortlistDBOperations.sharedInstance.getShortlist()
        self.createUnfilteredMapModelFromDatabase { [weak self] unfilteredMapModel in
            guard let strongSelf = self else { return }
            strongSelf.unfilteredMapModel = unfilteredMapModel
            let interestFilterSet = strongSelf.interestsRepository.loadInterestsSet()
            strongSelf.createFilteredMapModel(unfilteredModel: unfilteredMapModel, interestFilterSet: interestFilterSet, completed: { (filteredMapModel) in
                strongSelf.filteredMapModel = filteredMapModel
                strongSelf.reloadMapFromModel(mapModel: filteredMapModel, completed: {
                    completion()
                })
            })
        }
    }
}

// MARK:- Conform to UIViewControllerTransitioningDelegate
extension MapViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
        popupAnimator.popupAnimatorDidDismiss = { [weak self] _ in
            self?.pressedPinOrCluster?.removeFromSuperview()
        }

        popupAnimator.originFrame = pressedPinOrCluster!.frame
        
        popupAnimator.presenting = true
        return popupAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        popupAnimator.presenting = false
        return popupAnimator
    }
}

extension MapViewController : F4SCompanyDatabaseAvailabilityObserving {
    func newStagedDatabaseIsAvailable(url: URL) {
        guard FileHelper.fileExists(path: url.path) else {
            return
        }
        reloadMap()
    }
    
    func newDatabaseIsDownloading(progress: Double) {
        DispatchQueue.main.async { [weak self] in
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 0
            let text = formatter.string(for: progress * 100.0)! + "%"
            self?.userMessageHandler.updateOverlayCaption("loading..." + text)
        }
    }
}

extension MapViewController : SearchViewDelegate {
    func searchView(_ view: SearchViewProtocol, didSelectItem indexPath: IndexPath) {
        guard let item = activeDatasource?.itemForIndexPath(indexPath) else { return }
        switch view.state {
        case .collapsed, .horizontallyExpanded:
            return
        case .searchingLocation:
            setUserLocation(from: item.primaryText, placeId: item.uuidString)
            
        case .searchingPeople:
            print("Display person: \(item.matchOnText)")
        case .searchingCompany:
            guard
                let uuid = item.uuidString,
                let company = DatabaseOperations.sharedInstance.companyWithUUID(uuid) else { return }
            coordinator?.showDetail(company: company, originScreen: ScreenName.companySearch)
        }
        searchView.minimizeSearchUI()
    }
    
    func searchView(_ view: SearchViewProtocol, didChangeText text: String) {
        activeDatasource?.setSearchString(text, completion: { [weak self] in
            self?.searchView.refreshFromDatasource()
        })
    }
    
    func searchView(_ view: SearchViewProtocol, didChangeState state: SearchViewStateMachine.State) {
        searchView.dataSource = activeDatasource
    }
    
    var activeDatasource: SearchDataSourcing? {
        switch searchView.state {
        case .collapsed, .horizontallyExpanded: return nil
        case .searchingLocation: return placesDataSource
        case .searchingPeople: return peopleDataSource
        case .searchingCompany:
            companyDataSource.userLocation = userLocation?.coordinate
            return companyDataSource
            
        }
    }
}
