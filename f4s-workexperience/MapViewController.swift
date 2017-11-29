//
//  MapViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 09/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Reachability

enum CamerWillMoveAction {
    case explodeCluster(GMUCluster)
    case other
    case none
}

class MapViewController: UIViewController {
    
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
        return UIEdgeInsets(top: searchView.bounds.height + 60, left: 60, bottom: 60, right: 60)
    }
    
    /// Container view for the search text box and closely associated controls
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var searchLocationTextField: AutoCompleteTextField!
    
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
    
    var autoCompleteFilter: GMSAutocompleteFilter?
    var placesClient: GMSPlacesClient?
    var backgroundView = UIView()
    var shouldRequestAuthorization: Bool?
    var pressedPinOrCluster: UIView?
    
    lazy var partnersModel: PartnersModel = {
        let p = PartnersModel.sharedInstance
        p.getPartners(completed: { (_) in
            return
        })
        return p
    }()
    
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
            guard let previousFavouriteSet = previousFavouriteSet else {
                self.previousFavouriteSet = favouriteSet
                return
            }
            if previousFavouriteSet != favouriteSet {
                self.previousFavouriteSet = favouriteSet
                self.reloadMapFromModel(mapModel: unfilteredMapModel!, completed: {})
            }
        }
    }
    
    /// The company currently selected by the user (if any)
    var selectedCompany: Company?
    
    var infoWindowView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dbService = DatabaseService.sharedInstance
        dbService.setDatabaseDownloadProtocol(viewCtrl: self)
        adjustAppeareance()
        handleTextFieldInterfaces()
        setupMap()
        setupReachability(nil, useClosures: true)
        startNotifier()
        partnersModel.showWillProvidePartnerLater = true

        if dbService.isDownloadInProgress {
            if let view = self.navigationController?.tabBarController?.view {
                MessageHandler.sharedInstance.showLoadingOverlay(view)
            }
        } else {
            reloadMapFromDatabase { [weak self] in
                self?.moveCameraToBestPosition()
                MessageHandler.sharedInstance.hideLoadingOverlay()
            }
        }
        
        moveCameraToBestPosition()
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
        
        vc.setCompanies(companies)
        
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    deinit {
        stopNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
        displayRefineSearchLabelAnimated()
        favouriteList = ShortlistDBOperations.sharedInstance.getShortlistForCurrentUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFramesAndSizes()
    }
    
    
    var hasMovedToBestPosition: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !partnersModel.hasSelectedPartner {
            selectPartner()
        }
        applyBranding()
        if !hasMovedToBestPosition {
            moveCameraToBestPosition()
            hasMovedToBestPosition = true
        }
    }
    
    func applyBranding() {
        
    }
    
    func selectPartner() {
        let vc = UIStoryboard(name: "SelectPartner", bundle: Bundle.main).instantiateInitialViewController()!
        present(vc, animated: true, completion: nil)
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

//MARK:- Handle download of company database
protocol DatabaseDownloadProtocol: class {
    func finishDownloadProtocol()
}

// MARK:- Conform to DatabaseDownloadProtocol
extension MapViewController: DatabaseDownloadProtocol {
    internal func finishDownloadProtocol() {
        reloadMapFromDatabase { [weak self] in
            self?.moveCameraToBestPosition()
            MessageHandler.sharedInstance.hideLoadingOverlay()
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
        searchView.layer.cornerRadius = 10
        setupButtons()
        setupLabels()
        self.view.layoutIfNeeded()
        configureTextField()
    }
    
    fileprivate func setupButtons() {
        filtersButton.layer.cornerRadius = filtersButton.bounds.height / 2
        filtersButton.layer.masksToBounds = true
        filtersButton.setBackgroundColor(color: UIColor(netHex: Colors.waterBlue), forUIControlState: .normal)
        filtersButton.setBackgroundColor(color: UIColor(netHex: Colors.azure), forUIControlState: .highlighted)
        filtersButton.setImage(UIImage(named: "filtersIcon"), for: .normal)
        filtersButton.setImage(UIImage(named: "filtersIcon"), for: .highlighted)
    }
    
    fileprivate func setupLabels() {
        let refineStr = NSLocalizedString("Refine your search!", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.tailIndent = 163
        
        self.refineSearchLabel.attributedText = NSAttributedString(
            string: refineStr,
            attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.paragraphStyle: paragraph])
    }
    
    fileprivate func setupFramesAndSizes() {
        if self.searchView.frame.size.width != 1000 {
            self.searchLocationTextField.autoCompleteTableWidth = self.searchView.bounds.width
        }
    }
    
    func adjustNavigationBar() {
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.black)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    fileprivate func configureTextField() {
        searchLocationTextField.enablesReturnKeyAutomatically = true
        searchLocationTextField!.setupAutocompleteTable(searchView, rootView: self.view)
        searchLocationTextField.borderStyle = .none
        searchLocationTextField.placeholder = NSLocalizedString("Search", comment: "")
        searchLocationTextField.isMapView = true
        searchLocationTextField.shouldTintClearButton = false
        searchLocationTextField.tintColor = UIColor(netHex: Colors.azure)
        
        searchLocationTextField!.backgroundColor = UIColor.white
        searchLocationTextField!.autoCompleteTextColor = UIColor(netHex: Colors.warmGrey)
        searchLocationTextField!.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 15.0)!
        searchLocationTextField!.autoCompleteCellHeight = 50
        searchLocationTextField!.maximumAutoCompleteCount = 3
        searchLocationTextField!.hidesWhenSelected = true
        searchLocationTextField!.hidesWhenEmpty = true
        searchLocationTextField!.enableAttributedText = true
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColor.black
        attributes[NSAttributedStringKey.font] = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        searchLocationTextField!.autoCompleteAttributes = attributes
        
        searchLocationTextField.returnKeyType = .search
        searchLocationTextField.autocorrectionType = .no
        
        self.refineSearchLabel.isHidden = true
        self.refineSearchLabel.layer.cornerRadius = 10
        self.refineSearchLabel.layer.masksToBounds = true
    }
    
    func setupInfoWindow(company: Company) -> UIView {
        guard let infoWindow = Bundle.main.loadNibNamed("InfoWindowView", owner: self, options: nil)?.first as? InfoWindowView else {
            return UIView()
        }
        
        infoWindow.companyNameLabel.attributedText = NSAttributedString(
            string: company.name, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor.black])
        
        infoWindow.industryNameLabel.attributedText = NSAttributedString(
            string: company.industry, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Style.smallerMediumTextSize, weight: UIFont.Weight.light), NSAttributedStringKey.foregroundColor: UIColor.black])
        
        if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
            ImageService.sharedInstance.getImage(url: url, completed: {
                succeeded, image in
                DispatchQueue.main.async {
                    if succeeded && image != nil {
                        infoWindow.logoImageView.image = image!
                    } else {
                        infoWindow.logoImageView.image = UIImage(named: "DefaultLogo")
                    }
                }
            })
        } else {
            infoWindow.logoImageView.image = UIImage(named: "DefaultLogo")
        }
        
        if company.rating < 0.5 {
            infoWindow.ratingStackView.removeFromSuperview()
        } else {
            setInfoWindowStars(infoWindow: infoWindow, unroundedRating: company.rating)
            
            infoWindow.ratingLabel.attributedText = NSAttributedString(
                string: String(format: "%.1f", company.rating),
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Style.biggerVerySmallTextSize, weight: UIFont.Weight.semibold),
                             NSAttributedStringKey.foregroundColor: UIColor.black])
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
            slideInTransition.type = kCATransitionPush
            slideInTransition.subtype = kCATransitionFromRight
            slideInTransition.duration = 1
            slideInTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            slideInTransition.fillMode = kCAFillModeRemoved
            
            refineSearchLabel.layer.add(slideInTransition, forKey: "slideInFromRight")
        case .slideOut:
            let slideOutTransition = CATransition()
            if let delegate: CAAnimationDelegate = completionDelegate {
                slideOutTransition.delegate = delegate
            }
            slideOutTransition.type = kCATransitionPush
            slideOutTransition.subtype = kCATransitionFromLeft
            slideOutTransition.duration = 1
            slideOutTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            slideOutTransition.fillMode = kCAFillModeRemoved
            // slideOutTransition.delegate =
            refineSearchLabel.layer.add(slideOutTransition, forKey: "slideOutFromLeft")
        }
    }
    
    func displayRefineSearchLabelAnimated() {
        if self.refineSearchLabel.isHidden && InterestDBOperations.sharedInstance.interestsForCurrentUser().count == 0 {
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
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isFirstLaunch)
        mapView.delegate = self
        
        // cluster algorithm setup
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let iconGenerator = self.iconGeneratorWithImages()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        
        // autocomplete places api setup
        placesClient = GMSPlacesClient()
        self.autoCompleteFilter = GMSAutocompleteFilter()
        self.autoCompleteFilter?.country = "gb"
        
        locationManager = makeLocationManager()
        if let shouldRequestAuthorization = self.shouldRequestAuthorization {
            if shouldRequestAuthorization {
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        
        mapView.settings.myLocationButton = false
        mapView.setMinZoom(6.0, maxZoom: 16.0)
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
    }
    
    fileprivate func iconGeneratorWithImages() -> GMUClusterIconGenerator {
        return CustomClusterIconGenerator()
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
        let topLeftPoint = CGPoint(x: self.searchView.frame.minX, y: self.searchView.frame.maxY)
        let bottomRightPoint = CGPoint(x: self.searchView.frame.maxX, y: mapView.bounds.height)
        let topRightPoint = CGPoint(x: self.searchView.frame.maxX, y: self.searchView.frame.maxY)
        let bottomLeftPoint = CGPoint(x: self.searchView.frame.minX, y: mapView.bounds.height)

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

// MARK: - UITextFieldDelegate + Search Methods
extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField is AutoCompleteTextField {
            (textField as! AutoCompleteTextField).autoCompleteTableView?.isHidden = true
            textField.resignFirstResponder()
            let mapSearchLocation = textField.text ?? ""
            
            if (mapSearchLocation.isEmpty) == false {
                
                if let autoCompletePlaceIds = (textField as! AutoCompleteTextField).autoCompletePlacesIds {
                    self.setUserLocation(from: mapSearchLocation, placeId: autoCompletePlaceIds.first)
                } else {
                    self.setUserLocation(from: mapSearchLocation, placeId: nil)
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField is AutoCompleteTextField {
            self.backgroundView.frame = self.view.frame
            self.backgroundView.backgroundColor = UIColor(netHex: Colors.black).withAlphaComponent(0.0)
            UIView.animate(withDuration: 0.3, animations: { () in
                self.backgroundView.backgroundColor = UIColor(netHex: Colors.black).withAlphaComponent(0.5)
            })
            
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endSearch(_:)))
                backgroundView.addGestureRecognizer(tapGesture)
            }
            self.view.addSubview(backgroundView)
            self.view.bringSubview(toFront: searchView)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField is AutoCompleteTextField {
            (textField as! AutoCompleteTextField).autoCompleteTableView?.isHidden = true
            UIView.animate(withDuration: 0.3, animations: { () in
                self.backgroundView.backgroundColor = UIColor(netHex: Colors.black).withAlphaComponent(0.0)
            }, completion: { _ in
                self.backgroundView.removeFromSuperview()
            })
        }
    }
    
    func displayDefaultSearch() {
        self.searchLocationTextField.becomeFirstResponder()
    }
    
    @objc func endSearch(_: UITapGestureRecognizer) {
        self.searchLocationTextField.resignFirstResponder()
    }
    
    fileprivate func handleTextFieldInterfaces() {
        searchLocationTextField!.onTextChange = { [weak self] text in
            if !text.isEmpty {
                var places: [String] = []
                var placesIds: [String] = []
                guard let strongSelf = self else {
                    return
                }
                strongSelf.placesClient?.autocompleteQuery(text, bounds: nil, filter: strongSelf.autoCompleteFilter, callback: { results, error in
                    guard error == nil,
                        let strongResults = results else {
                            print("Autocomplete error \(error!)")
                            return
                    }
                    
                    for result in strongResults {
                        if let placeId = result.placeID {
                            placesIds.append(placeId)
                        }
                        places.append(result.attributedFullText.string)
                    }
                    strongSelf.searchLocationTextField.autoCompletePlacesIds = placesIds
                    strongSelf.searchLocationTextField!.autoCompleteStrings = places
                })
            }
        }
        
        searchLocationTextField!.onSelect = { [weak self] text, _ in
            self?.searchLocationTextField.resignFirstResponder()
            self?.searchLocationTextField.text = text
            let indexOfString = self?.searchLocationTextField.autoCompleteStrings?.index(of: text)
            if let index = indexOfString {
                let placeId = self?.searchLocationTextField.autoCompletePlacesIds?[index]
                self?.setUserLocation(from: text, placeId: placeId)
            } else {
                self?.setUserLocation(from: text, placeId: nil)
            }
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
        CustomNavigationHelper.sharedInstance.showCompanyDetailsPopover(parentCtrl: self, company: company)
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
            moveCameraToBestPosition()
            
        case .denied:
            mapView.isMyLocationEnabled = false
            print("location services denied")
            
            displayDefaultSearch()
            
        case .authorizedAlways:
            locationManager!.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            
        case .restricted:
            mapView.isMyLocationEnabled = false
            print("location services restricted")
            displayDefaultSearch()
            
        case .notDetermined:
            print("not determined")
            if !self.shouldRequestAuthorization! {
                displayDefaultSearch()
            }
        }
        self.lastAuthorizationStatus = status
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager!.stopUpdatingLocation()
    }
}

// MARK: - User interaction
extension MapViewController {
    
    @IBAction func myLocationButtonTouched(_: UIButton) {
        print("tapped mylocationbtn")
        
        if searchLocationTextField.isFirstResponder {
            searchLocationTextField.resignFirstResponder()
        }
        if let location = mapView.myLocation?.coordinate {
            moveAndZoomCamera(to: location)
        } else {
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
                MessageHandler.sharedInstance.presentEnableLocationInfo(parentCtrl: self)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager?.requestWhenInUseAuthorization()
            }
        }
    }
    
    @IBAction func filtersButtonTouched(_: UIButton) {
        let interestsStoryboard = UIStoryboard(name: "InterestsView", bundle: nil)
        let interestsCtrl = interestsStoryboard.instantiateViewController(withIdentifier: "interestsCtrl") as! InterestsViewController
        interestsCtrl.visibleBounds = self.visibleMapBounds
        interestsCtrl.mapModel = unfilteredMapModel
        interestsCtrl.delegate = self
        let interestsCtrlNav = RotationAwareNavigationController(rootViewController: interestsCtrl)
        hideRefineSearchLabelAnimated()
        self.navigationController?.present(interestsCtrlNav, animated: true, completion: nil)
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
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: nil)
        reachability = nil
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.isReachableByAnyMeans {
            debugPrint("network is reachable")
            let dbService = DatabaseService.sharedInstance
            if !dbService.isLocalDatabaseAvailable() && !dbService.isDownloadInProgress {
                dbService.getLatestDatabase()
                DispatchQueue.main.async {
                    if let view = self.navigationController?.tabBarController?.view {
                        DatabaseService.sharedInstance.getLatestDatabase()
                        MessageHandler.sharedInstance.showLoadingOverlay(view)
                    }
                }
            }
        } else {
            debugPrint("network not reachable")
            if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) == nil {
                DispatchQueue.main.async {
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
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
            LocationHelper.sharedInstance.googleGeocodeAddressString(address, placeId) { _, coordinates in
                switch coordinates {
                case .value(let coordinates):
                    self.userLocation = CLLocation(latitude: coordinates.value.latitude, longitude: coordinates.value.longitude)
                case .error(let err):
                    if err == "NoConnectivity" {
                        let title = NSLocalizedString("No data connectivity", comment: "")
                        let errorMsg = NSLocalizedString("You appear to be offline at the moment. Please try again later when you have a working internet connection.",
                                                         comment: "")
                        MessageHandler.sharedInstance.displayWithTitle(title, errorMsg, parentCtrl: self)
                        debugPrint(err)
                    } else {
                        let title = NSLocalizedString("Location Not Found", comment: "")
                        let errorMsg = NSLocalizedString("We cannot find the location you entered. Please try again", comment: "")
                        MessageHandler.sharedInstance.displayWithTitle(title, errorMsg, parentCtrl: self)
                        debugPrint(err)
                    }
                case let .deffinedError(error):
                    log.debug(error)
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
    /// - parameter unfilterdModel: The starting MapModel whose content is to be filtered into a new MapModel
    /// - parameter interestFilterSet: The set of interests to filter companies by. A company must have at least one interest in the interestFilterSet to qualify
    /// - parameter completed: Calls back with the filtered MapModel
    func createFilteredMapModel(unfilteredModel: MapModel,
                                interestFilterSet: F4SInterestSet,
                                completed: @escaping (MapModel) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredModel = MapModel(allCompanyPinsSet: unfilteredModel.allCompanyPins,
                                         allInterests: unfilteredModel.interestsModel.allInterests,
                                         filtereredBy: interestFilterSet)
            completed(filteredModel)
        }
    }
    
    /// Asynchronously creates an unfiltered map model by reading directly from the databas
    ///
    /// - parameter completion: Calls back with the newly created MapModel
    func createUnfilteredMapModelFromDatabase(completion: @escaping (MapModel) -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dbOps = DatabaseOperations.sharedInstance
            dbOps.getAllCompanies(completed: { companies in
                dbOps.getAllInterests(completed: { (interests) in
                    let mapModel = MapModel(
                        allCompanies: companies,
                        allInterests:interests,
                        selectedInterests: nil)
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
    
    /// Asynchronously reloads the map from datastructures read from the database
    ///
    /// - parameter completion: Call back when the reload is complete
    func reloadMapFromDatabase(completion: @escaping () -> Void ) {
        if !(DatabaseService.isLocalDatabaseAvailable() && DatabaseOperations
            .sharedInstance.isConnected) {
            completion()
            return
        }
        self.favouriteList = ShortlistDBOperations.sharedInstance.getShortlistForCurrentUser()
        self.createUnfilteredMapModelFromDatabase { [weak self] unfilteredMapModel in
            guard let strongSelf = self else { return }
            strongSelf.unfilteredMapModel = unfilteredMapModel
            let interestFilterSet = InterestDBOperations.sharedInstance.interestsForCurrentUser()
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
        popupAnimator.originFrame = pressedPinOrCluster!.superview!.convert(pressedPinOrCluster!.frame, to: nil)
        
        popupAnimator.presenting = true
        return popupAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        popupAnimator.presenting = false
        return popupAnimator
    }
}
