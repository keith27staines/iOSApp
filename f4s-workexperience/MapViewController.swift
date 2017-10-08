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
import ReachabilitySwift

class MapViewController: UIViewController {
    /// Displays the map
    @IBOutlet var mapView: GMSMapView!
    
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
    
    /// A guarenteed location that will be the user's actual location (i.e, `myLocation`) if available, or if not then the location last manually specified by the user, or failing that the approximate centroid of the UK
    var location: CLLocationCoordinate2D {
        return (self.mapView.myLocation?.coordinate ?? userLocation?.coordinate) ?? MapViewController.centerUkCoord
    }
    
    var autoCompleteFilter: GMSAutocompleteFilter?
    var placesClient: GMSPlacesClient?
    var backgroundView = UIView()
    var shouldRequestAuthorization: Bool?
    
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
        return GMSCoordinateBounds(region: getVisibleRegion())
    }
    
    /// Manages searches for businesses
    var mapModel: MapModel?
    
    /// Used to determine whether there is internet connectivity
    var reachability: Reachability?
    
    /// Indicates whether the company database is currently downloading
    var downloadIsInProgress: Bool = true
    
    /// The set of all pins currently added to the map
    var emplacedCompanyPins: F4SCompanyPinSet = []
    
    /// The list of currently favourited companies
    var favouriteList: [Shortlist] = []
    
    /// The company currently selected by the user (if any)
    var selectedCompany: Company?
    
    var infoWindowView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) == nil {
            self.downloadIsInProgress = true
            if let view = self.navigationController?.tabBarController?.view {
                MessageHandler.sharedInstance.showLoadingOverlay(view)
            }
            DatabaseService.sharedInstance.setDatabaseDownloadProtocol(viewCtrl: self)
        }
        adjustAppeareance()
        handleTextFieldInterfaces()
        setupMap()
        setupReachability(nil, useClosures: true)
        startNotifier()
        createMapModel()
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
    
    /// Creates the map model
    func createMapModel() {
        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseOperations.sharedInstance.getAllCompanies(completed: { [weak self] (companies) in
                guard let strongSelf = self else { return }
                let mapModel = MapModel(allCompanies: companies)
                strongSelf.mapModel = mapModel
                strongSelf.clearMap()
                let centerUK = MapViewController.centerUkCoord
                let camera = GMSCameraPosition(target: centerUK,
                                               zoom: 6,
                                               bearing: 0,
                                               viewingAngle: 0)
                strongSelf.mapView.camera = camera
                strongSelf.addPinsFromVisibleBoundsToMap()
                if let target = strongSelf.mapView.myLocation ?? strongSelf.userLocation {
                    strongSelf.moveAndZoomCamera(to: target.coordinate)
                } else {
                    strongSelf.moveCamera()
                }
            })
        }
    }
}

//MARK:- Handle download of company database
protocol DatabaseDownloadProtocol: class {
    func finishDownloadProtocol()
}

extension MapViewController: DatabaseDownloadProtocol {
    internal func finishDownloadProtocol() {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) != nil {
            self.downloadIsInProgress = false
            MessageHandler.sharedInstance.hideLoadingOverlay()
            createMapModel()
        }
    }
}

// MARK:- Managing pins on map
extension MapViewController {
    /// Clears the map and associated data structures including:
    /// 1. mapView
    /// 2. emplacedCompanyPins
    /// 3. clusterManager
    func clearMap() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mapView.clear()
            strongSelf.emplacedCompanyPins.removeAll()
            strongSelf.clusterManager.clearItems()
        }
    }

    /// Gets the pins in the currently visible area and adds them to the map
    func addPinsFromVisibleBoundsToMap(completion: ((F4SCompanyPinSet) -> Void)? = nil) {
        guard let bounds = visibleMapBounds else { return }
        mapModel?.getCompanyPinSet(for: bounds) { [weak self] companyPins in
            self?.addPinsToMap(pins: companyPins)
            completion?(companyPins)
        }
    }
    
    /// Adds pins to the Map and its associated data structures:
    /// 1. clusterManager
    /// 2. emplacedCompanyPins
    func addPinsToMap(pins: F4SCompanyPinSet) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            for pin in pins {
                strongSelf.addPinToMap(pin: pin)
            }
        }
    }
    
    /// Adds the specified pin to the map and its associated data structures:
    /// 1. clusterManager
    /// 2. emplacedCompanyPins
    private func addPinToMap(pin: F4SCompanyPin) {
        if !emplacedCompanyPins.contains(pin) {
            clusterManager.add(pin)
            emplacedCompanyPins.insert(pin)
        }
    }
    
    /// Returns true if the specified pin's company has been favourited, otherwise returns false
    func shouldBeFavouritePin(companyPin: F4SCompanyPin) -> Bool {
        if let _ = self.favouriteList.filter({ $0.companyUuid == companyPin.companyUuid.replacingOccurrences(of: "-", with: "") }).first {
            return true
        }
        let companyList = self.emplacedCompanyPins.filter({$0.position == companyPin.position})
        if companyList.count > 1 {
            for comp in companyList {
                if let _ = self.favouriteList.filter({ $0.companyUuid == comp.companyUuid.replacingOccurrences(of: "-", with: "") }).first {
                    return true
                }
            }
        }
        return false
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
        
        self.refineSearchLabel.attributedText = NSAttributedString(string: refineStr, attributes: [
            NSFontAttributeName: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize,
                                                      weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: UIColor.black,
            NSParagraphStyleAttributeName: paragraph,
            ])
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
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
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
        infoWindow.companyNameLabel.attributedText = NSAttributedString(string: company.name,
                                                                        attributes: [
                                                                            NSFontAttributeName: UIFont.systemFont(ofSize: Style.largeTextSize,
                                                                                                                   weight: UIFontWeightSemibold),
                                                                            NSForegroundColorAttributeName: UIColor.black,
                                                                            ])
        infoWindow.industryNameLabel.attributedText = NSAttributedString(string: company.industry,
                                                                         attributes: [
                                                                            NSFontAttributeName: UIFont.systemFont(ofSize: Style.smallerMediumTextSize,
                                                                                                                   weight: UIFontWeightLight),
                                                                            NSForegroundColorAttributeName: UIColor.black,
                                                                            ])
        
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
        
        if company.rating == 0 {
            infoWindow.ratingStackView.removeFromSuperview()
        } else {
            let roundedRating = company.rating.round()
            if roundedRating == 0 {
                infoWindow.ratingStackView.removeFromSuperview()
            } else {
                infoWindow.ratingLabel.attributedText = NSAttributedString(string: String(format: "%.1f", company.rating),
                                                                           attributes: [
                                                                            NSFontAttributeName: UIFont.systemFont(ofSize: Style.biggerVerySmallTextSize,
                                                                                                                   weight: UIFontWeightSemibold),
                                                                            NSForegroundColorAttributeName: UIColor.black,
                                                                            ])
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
//        if self.refineSearchLabel.isHidden && InterestDBOperations.sharedInstance.getInterestForCurrentUser().count == 0 {
//            self.refineLabelContainerView.isHidden = false
//            self.setupSlideInAnimation(transitionType.slideIn, completionDelegate: self)
//            self.refineSearchLabel.isHidden = false
//        }
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
    }
    
    fileprivate func iconGeneratorWithImages() -> GMUClusterIconGenerator {
        return CustomClusterIconGenerator()
    }
    
    fileprivate func makeLocationManager() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }
}

// MARK:- Camera position management
extension MapViewController  {
    /// Moves the camera to the specified location and sets the zoom to the specified value. If the location is omitted, then the centreUKLocation will be used. If the zoom is omitted, then the minimum zoom will be used
    func moveCamera(to location: CLLocationCoordinate2D? = MapViewController.centerUkCoord,
                    zoom: Float = MapViewController.zoomMinimum) {
        let cameraPosition = GMSCameraPosition(target: location!,
                                               zoom: zoom,
                                               bearing: 0,
                                               viewingAngle: 0)
        mapView.animate(to: cameraPosition)
        
    }
    
    /// Moves and zooms the camera to display a reasonable number of pins around the specified location.
    func moveAndZoomCamera(to location: CLLocationCoordinate2D) {
        guard let mapModel = mapModel else {
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
                self?.mapModel = mapModel
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
    
    func endSearch(_: UITapGestureRecognizer) {
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
    
    func mapView(_: GMSMapView, willMove gesture: Bool) {
        if gesture {
            hideRefineSearchLabelAnimated()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.selectedCompany = companyFromMarker(marker: marker)
        self.mapView.selectedMarker = marker
        var point: CGPoint = mapView.projection.point(for: marker.position)
        point.y -= 50
        let camera: GMSCameraUpdate = GMSCameraUpdate.setTarget(mapView.projection.coordinate(for: point))
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.tracksInfoWindowChanges = true
        
        mapView.animate(with: camera)
        return true
    }
    
    func mapView(_: GMSMapView, idleAt _: GMSCameraPosition) {
        
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
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.animate(with: update)
    }
}

// MARK: - CLLocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
            
        case .authorizedWhenInUse:
            locationManager!.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            
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
//        let interestsStoryboard = UIStoryboard(name: "InterestsView", bundle: nil)
//        let interestsCtrl = interestsStoryboard.instantiateViewController(withIdentifier: "interestsCtrl") as! InterestsViewController
//        if currentBounds == nil {
//            self.currentBounds = GMSCoordinateBounds(region: getVisibleRegion())
//        }
//        interestsCtrl.currentBounds = currentBounds
//        interestsCtrl.mapModel = mapModel
//        let interestsCtrlNav = RotationAwareNavigationController(rootViewController: interestsCtrl)
//        hideRefineSearchLabelAnimated()
//        self.navigationController?.present(interestsCtrlNav, animated: true, completion: nil)
    }
}

// MARK: - Reachability Setup
extension MapViewController {
    
    func setupReachability(_: String?, useClosures _: Bool) {
        let reachability = Reachability()
        self.reachability = reachability
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
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
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            debugPrint("network is reachable")
            if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) == nil && !self.downloadIsInProgress {
                self.downloadIsInProgress = true
                DispatchQueue.main.async {
                    if let view = self.navigationController?.tabBarController?.view {
                        MessageHandler.sharedInstance.showLoadingOverlay(view)
                    }
                }
                DatabaseService.sharedInstance.getLatestDatabase()
            }
        } else {
            debugPrint("network not reachable")
            if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) == nil {
                self.downloadIsInProgress = false
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
    
    /// Returns the Company corresponding to the specified marker
    func companyFromMarker(marker: GMSMarker) -> Company? {
        guard let pin = marker.userData as? F4SCompanyPin else {
            return nil
        }
        return companyWithUuid(pin.companyUuid)
    }
    
    /// Returns the Company with the specified UUID
    func companyWithUuid(_ uuid: String) -> Company? {
        return DatabaseOperations.sharedInstance.companyWithUuid(uuid)
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
