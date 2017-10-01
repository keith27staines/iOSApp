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
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var searchLocationTextField: AutoCompleteTextField!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var refineSearchLabel: UILabel!
    @IBOutlet weak var refineLabelContainerView: UIView!
    
    fileprivate var clusterManager: GMUClusterManager!
    fileprivate var locationManager: CLLocationManager?
    fileprivate var lastAuthorizationStatus: CLAuthorizationStatus?
    
    var autoCompleteFilter: GMSAutocompleteFilter?
    var placesClient: GMSPlacesClient?
    var backgroundView = UIView()
    var shouldRequestAuthorization: Bool?
    var userLocation: CLLocation?
    var currentBounds: GMSCoordinateBounds? {
        set {
            mapModel.currentBounds = newValue
        }
        get {
            return mapModel.currentBounds
        }
    }
    var mapModel: MapModel = MapModel()
    
    var reachability: Reachability?
    var downloadIsInProgress: Bool = true
    var didGetCompaniesNearUser: Bool = false
    var shouldLimitDisplayedCompanies: Bool = true
    
    var markers: [POIItem] = []
    var companies: [Company] = [] {
        didSet {
            updateMarkers()
        }
    }
    var favouriteList: [Shortlist] = []
    
    var selectedCompany: Company?
    var infoWindowView: UIView?
    var numberOfActions: Int = 0
    var didTappedMarker: Bool = false
    
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
}

extension MapViewController: DatabaseDownloadProtocol {
    internal func finishDownloadProtocol() {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.companyDatabaseCreatedDate) != nil {
            self.downloadIsInProgress = false
            MessageHandler.sharedInstance.hideLoadingOverlay()
            if let location = mapView.myLocation ?? self.userLocation {
                self.shouldLimitDisplayedCompanies = true
                getCompaniesInLocationWithInterests(coordinates_start: location.coordinate, coordinates_end: location.coordinate, isNearLocation: true)
            }
        }
    }
}

protocol DatabaseDownloadProtocol: class {
    func finishDownloadProtocol()
}

// MARK: - UI Setup
extension MapViewController {
    
    func updateMarkers() {
        mapView.clear()
        clusterManager.clearItems()
        self.markers = []
        let unfavouriteView = UIView()
        unfavouriteView.frame = CGRect(x: 0, y: 0, width: 19, height: 28)
        let unfavouriteMarkerIcon = UIImage(named: "markerIcon")
        let unfavouriteMarkerImageView = UIImageView(image: unfavouriteMarkerIcon)
        unfavouriteView.addSubview(unfavouriteMarkerImageView)
        
        let favouriteView = UIView()
        favouriteView.frame = CGRect(x: 0, y: 0, width: 19, height: 28)
        let markerFavouriteIcon = UIImage(named: "markerFavouriteIcon")
        let markerFavouriteImageView = UIImageView(image: markerFavouriteIcon)
        favouriteView.addSubview(markerFavouriteImageView)
        
        var view = UIView()
        
        for (i, company) in companies.enumerated() {
            if shouldBeFavouritePin(company: company) {
                view = favouriteView
            } else {
                view = unfavouriteView
            }
            let position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
            let index = CInt(i)
            if let selectedComp = self.selectedCompany {
                if selectedComp.id == company.id {
                    // shouldShowView -> true
                    if let item = POIItem(position: position, name: view, index: index, shouldShowView: true) { // name - custom view for marker
                        self.markers.append(item)
                        clusterManager.add(item)
                        continue
                    }
                }
            }
            if let item = POIItem(position: position, name: view, index: index, shouldShowView: false) { // name - custom view for marker
                self.markers.append(item)
                clusterManager.add(item)
            }
        }
        clusterManager.cluster()
    }
    
    func shouldBeFavouritePin(company: Company) -> Bool {
        if let _ = self.favouriteList.filter({ $0.companyUuid == company.uuid.replacingOccurrences(of: "-", with: "") }).first {
            return true
        }
        let companyList = self.companies.filter({$0.latitude == company.latitude && $0.longitude == company.longitude})
        if companyList.count > 1 {
            for comp in companyList {
                if let _ = self.favouriteList.filter({ $0.companyUuid == comp.uuid.replacingOccurrences(of: "-", with: "") }).first {
                    return true
                }
            }
        }
        return false
    }
    
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
                self?.moveCameraToAddress(text, placeId: placeId)
            } else {
                self?.moveCameraToAddress(text, placeId: nil)
            }
        }
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
        if self.refineSearchLabel.isHidden && InterestDBOperations.sharedInstance.getInterestForCurrentUser().count == 0 {
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
        let centerUkCoord = CLLocationCoordinate2DMake(52.533505, -1.445217)
        let camera = GMSCameraPosition(target: centerUkCoord, zoom: 6, bearing: 0, viewingAngle: 0)
        mapView.camera = camera
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
    
    func moveCameraToAddress(_ address: String, placeId: String?) {
        self.shouldLimitDisplayedCompanies = true
        
        let coordinates = address.components(separatedBy: ",")
        let lat = Double(coordinates[0])
        if coordinates.count < 3 && lat != nil {
            if let lng = Double(coordinates[1]) {
                let coord = CLLocationCoordinate2DMake(lat!, lng)
                self.moveCameraToCoordinates(coord)
            }
        } else {
            LocationHelper.sharedInstance.googleGeocodeAddressString(address, placeId) { _, coordinates in
                switch coordinates {
                case .value(let coordinates):
                    self.userLocation = CLLocation(latitude: coordinates.value.latitude, longitude: coordinates.value.longitude)
                    self.moveCameraToCoordinates(coordinates.value)
                    self.getCompaniesInLocationWithInterests(coordinates_start: coordinates.value, coordinates_end: coordinates.value, isNearLocation: true)
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
    
    func moveCameraToCoordinates(_ coordinates: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 16)
        self.mapView.animate(to: camera)
    }
    
    func moveCameraWithDinamicZoom() {
        if self.companies.count > 0 {
            var boundsFromMarkers = GMSCoordinateBounds(coordinate: (markers.first?.position)!, coordinate: (markers.first?.position)!)
            for marker in self.markers {
                boundsFromMarkers = boundsFromMarkers.includingCoordinate(marker.position)
            }
            self.currentBounds = boundsFromMarkers
            
            mapView.animate(with: GMSCameraUpdate.fit(boundsFromMarkers, with: UIEdgeInsets(top: searchView.bounds.height + 60, left: 60, bottom: 60, right: 60)))
        }
    }
    
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
    
    func getCompaniesInLocationWithInterests(coordinates_start: CLLocationCoordinate2D, coordinates_end: CLLocationCoordinate2D, isNearLocation: Bool, shouldReposition: Bool = true, isNearMyLocation: Bool = false) {
        let interestList = InterestDBOperations.sharedInstance.getInterestForCurrentUser()
        print("Calling getCompaniesInLocationWithInterests")
        if interestList.count > 0 {
            if isNearLocation || isNearMyLocation {
                DatabaseOperations.sharedInstance.getCompaniesNearLocationFirstThenFilter(longitude: coordinates_start.longitude, latitude: coordinates_start.latitude, interests: interestList, completed: { companies in
                    self.companies = companies
                    if shouldReposition && companies.count > 1 {
                        self.moveCameraWithDinamicZoom()
                    } else {
                        self.moveCameraToCoordinates(coordinates_start)
                    }
                })
            } else {
                DatabaseOperations.sharedInstance.getCompaniesInLocationWithFilters(startLongitude: coordinates_start.longitude, startLatitude: coordinates_start.latitude, endLongitude: coordinates_end.longitude, endLatitude: coordinates_end.latitude, interests: interestList, completed: {
                    companies in
                    if self.shouldAddSelectedCompany(startLongitude: coordinates_start.longitude, startLatitude: coordinates_start.latitude, endLongitude: coordinates_end.longitude, endLatitude: coordinates_end.latitude) {
                        if companies.contains(where: { (company) -> Bool in
                            if company.id == self.selectedCompany?.id {
                                return true
                            }
                            return false
                        }) {
                            self.companies = companies
                        } else {
                            var companyList = companies
                            companyList.append(self.selectedCompany!)
                            self.companies = companyList
                        }
                    } else {
                        self.companies = companies
                    }
                })
            }
            
        } else {
            if isNearLocation || isNearMyLocation {
                DatabaseOperations.sharedInstance.getCompaniesNearLocation(longitude: coordinates_start.longitude, latitude: coordinates_start.latitude, completed: {
                    companies in
                    self.companies = companies
                    if shouldReposition && companies.count > 1 {
                        self.moveCameraWithDinamicZoom()
                    } else {
                        self.moveCameraToCoordinates(coordinates_start)
                    }
                })
            } else {
                DatabaseOperations.sharedInstance.getCompaniesInLocation(startLongitude: coordinates_start.longitude, startLatitude: coordinates_start.latitude, endLongitude: coordinates_end.longitude, endLatitude: coordinates_end.latitude, completed: {
                    companies in
                    if self.shouldAddSelectedCompany(startLongitude: coordinates_start.longitude, startLatitude: coordinates_start.latitude, endLongitude: coordinates_end.longitude, endLatitude: coordinates_end.latitude) {
                        if companies.contains(where: { (company) -> Bool in
                            if company.id == self.selectedCompany?.id {
                                return true
                            }
                            return false
                        }) {
                            self.companies = companies
                        } else {
                            var companyList = companies
                            companyList.append(self.selectedCompany!)
                            self.companies = companyList
                        }
                    } else {
                        self.companies = companies
                    }
                })
            }
        }
    }
    
    func shouldAddSelectedCompany(startLongitude: Double, startLatitude: Double, endLongitude: Double, endLatitude: Double) -> Bool {
        guard let company = self.selectedCompany else {
            return false
        }
        let longitude = company.longitude
        let latitude = company.latitude
        if ((longitude >= startLongitude && longitude <= endLongitude) || (longitude <= startLongitude && longitude >= endLongitude)) && ((latitude >= startLatitude && latitude <= endLatitude) || (latitude <= startLatitude && latitude >= endLatitude)) {
            return true
        }
        return false
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
                    self.moveCameraToAddress(mapSearchLocation, placeId: autoCompletePlaceIds.first)
                } else {
                    self.moveCameraToAddress(mapSearchLocation, placeId: nil)
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
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_: GMSMapView, willMove gesture: Bool) {
        if gesture {
            hideRefineSearchLabelAnimated()
            self.shouldLimitDisplayedCompanies = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.selectedCompany = nil
        var point: CGPoint = mapView.projection.point(for: marker.position)
        point.y -= 50
        let camera: GMSCameraUpdate = GMSCameraUpdate.setTarget(mapView.projection.coordinate(for: point))
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.tracksInfoWindowChanges = true
        self.mapView.selectedMarker = marker
        self.didTappedMarker = true
        mapView.animate(with: camera)
        return true
    }
    
    func mapView(_: GMSMapView, idleAt _: GMSCameraPosition) {
        if self.didTappedMarker {
            self.didTappedMarker = false
            self.numberOfActions = 0
        } else {
            self.numberOfActions = 1
        }
        if !self.shouldLimitDisplayedCompanies {
            self.currentBounds = GMSCoordinateBounds(region: getVisibleRegion())
            if let northEast = currentBounds?.northEast, let southWest = currentBounds?.southWest {
                getCompaniesInLocationWithInterests(coordinates_start: southWest, coordinates_end: northEast, isNearLocation: false)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let index = (marker.userData as? POIItem)?.index else {
            return nil
        }
        let company = self.companies[Int(index)]
        self.shouldLimitDisplayedCompanies = true
        if self.numberOfActions == -1 {
            self.numberOfActions = 0
        } else if self.numberOfActions == 4 {
            self.numberOfActions = 0
        } else {
            self.numberOfActions += 1
        }
        if self.selectedCompany != nil {
            if let infoWindow = self.infoWindowView {
                return infoWindow
            }
        }
        self.selectedCompany = company
        self.infoWindowView = setupInfoWindow(company: company)
        return infoWindowView
    }
    
    func mapView(_: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let index = (marker.userData as? POIItem)?.index {
            let company = self.companies[Int(index)]
            CustomNavigationHelper.sharedInstance.showCompanyDetailsPopover(parentCtrl: self, company: company)
        }
    }
    
    func mapView(_: GMSMapView, didCloseInfoWindowOf _: GMSMarker) {
        self.numberOfActions += 1
        if self.numberOfActions == 1 {
            // close
            self.selectedCompany = nil
            self.numberOfActions = -1
        }
    }
}

// MARK: - GMUClusterManager Delegate
extension MapViewController: GMUClusterManagerDelegate {
    
    func clusterManager(_: GMUClusterManager, didTap cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.animate(with: update)
        self.currentBounds = GMSCoordinateBounds(region: getVisibleRegion())
    }
}

// MARK: - CLLocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case .authorizedWhenInUse:
            locationManager!.startUpdatingLocation()
            self.didGetCompaniesNearUser = false
            mapView.isMyLocationEnabled = true
            
        case .denied:
            mapView.isMyLocationEnabled = false
            print("location services denied")
            
            displayDefaultSearch()
            
        case .authorizedAlways:
            locationManager!.startUpdatingLocation()
            self.didGetCompaniesNearUser = false
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
        guard let myLocation = locations.first else {
            return
        }
        self.userLocation = myLocation
        if !didGetCompaniesNearUser {
            getCompaniesInLocationWithInterests(coordinates_start: myLocation.coordinate, coordinates_end: myLocation.coordinate, isNearLocation: false, isNearMyLocation: true)
        }
    }
}

extension CLLocation {
    func hasSameCoordinates(_ location: CLLocation) -> Bool {
        return location.coordinate.latitude == self.coordinate.latitude && location.coordinate.longitude == location.coordinate.longitude
    }
}

// MARK: - User interaction
extension MapViewController {
    
    @IBAction func myLocationButtonTouched(_: UIButton) {
        print("tapped mylocationbtn")
        
        if searchLocationTextField.isFirstResponder {
            searchLocationTextField.resignFirstResponder()
        }
        if let location = mapView.myLocation {
            self.shouldLimitDisplayedCompanies = true
            getCompaniesInLocationWithInterests(coordinates_start: location.coordinate, coordinates_end: location.coordinate, isNearLocation: false, isNearMyLocation: true)
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
        if currentBounds == nil {
            self.currentBounds = GMSCoordinateBounds(region: getVisibleRegion())
        }
        interestsCtrl.currentBounds = currentBounds
        interestsCtrl.mapModel = mapModel
        interestsCtrl.mapController = self
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
