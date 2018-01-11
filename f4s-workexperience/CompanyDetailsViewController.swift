//
//  CompanyDetailsViewController.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/14/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Reachability

class CompanyDetailsViewController: UIViewController {
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func toggleMapButtonPressed(_ sender: Any) {
        if mapView.isHidden {
            mapView.isHidden = false
            let height = firmDescriptionTextView.frame.origin.y + firmDescriptionTextView.frame.height - tableView.frame.origin.y
            self.mapViewHeightConstraint.constant = height
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            self.mapViewHeightConstraint.constant = 2
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: { [weak self] (complete) in
                self?.mapView.isHidden = true
            })
        }
    }
    
    @IBOutlet weak var seeAcountsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var firmDescriptionTextView: UITextView!
    @IBOutlet weak var firmNameLabel: UILabel!
    @IBOutlet weak var firmLogoImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var companyDetailsView: UIView!
    @IBOutlet weak var shortlistButton: UIButton!
    
    let backgroundPopoverView = UIView()
    var company: Company!
    var placement: Placement?
    var shortlist: [Shortlist] = []
    fileprivate let IndustryCellIdentifier: String = "industryIdentifier"
    fileprivate let RatingCellIdentifier: String = "ratingIdentifier"
    fileprivate let OtherCellIdentifier: String = "otherIdentifier"
    fileprivate var popupView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupAppearance()
        setupMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.firmDescriptionTextView.isScrollEnabled = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidRegisterForRemoteNotificationsNotification(_:)), name: NSNotification.Name(rawValue: "ApplicationDidRegisterForRemoteNotificationsNotification"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.firmDescriptionTextView.isScrollEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ApplicationDidRegisterForRemoteNotificationsNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func applicationDidRegisterForRemoteNotificationsNotification(_: NSNotification) {
        if let comp = self.company {
            CustomNavigationHelper.sharedInstance.presentCoverLetterController(parentCtrl: self, currentCompany: comp)
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension CompanyDetailsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.currentContext
    }

    func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool {
        backgroundPopoverView.removeFromSuperview()
        return true
    }
}

// MARK: - user interraction
extension CompanyDetailsViewController {
    
    @IBAction func shortlistButtonTouched(_: Any) {
        guard let company = company else {
            return
        }

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }

        if shortlist.contains(where: { $0.companyUuid == company.uuid }) {
            // company is shortlisted
            // remove company from shortlist + remove locally
            MessageHandler.sharedInstance.showLightLoadingOverlay(self.view)
            if let indexOfShortlist = shortlist.index(where: { $0.companyUuid == company.uuid }) {
                ShortlistService.sharedInstance.unshortlistCompany(favoriteUuid: shortlist[indexOfShortlist].uuid, deleteCompleted: {
                    [weak self]
                    _, result in
                    guard let strongSelf = self else {
                        MessageHandler.sharedInstance.hideLoadingOverlay()
                        return
                    }
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    switch result
                    {
                    case .value:
                        ShortlistDBOperations.sharedInstance.removeShortlistWithId(shortlistUuid: strongSelf.shortlist[indexOfShortlist].uuid)
                        DispatchQueue.main.async {
                            strongSelf.setShortlistButton()
                            strongSelf.showFavouriteView(isAddedToFavourites: false)
                        }
                        break
                    case let .error(error):
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                        break
                    case let .deffinedError(error):
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                        break
                    }
                })
            }
        } else {

            // company isn't shortlisted
            // shortlist company + save locally
            
            if shortlist.count >= AppConstants.maximumNumberOfShortlists {
                // reached the maximum number of shortlists
                CustomNavigationHelper.sharedInstance.showFavouriteMaximumPopover(parentCtrl: self)
                return
            }

            MessageHandler.sharedInstance.showLightLoadingOverlay(self.view)
            ShortlistService.sharedInstance.shortlistCompany(companyUuid: company.uuid, postCompleted: {
                [weak self]
                _, result in
                guard let strongSelf = self else {
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    return
                }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result
                {
                case let .value(boxed):
                    var shortlist = boxed.value
                    shortlist.companyUuid = company.uuid
                    ShortlistDBOperations.sharedInstance.saveShortlist(shortlist: shortlist)
                    DispatchQueue.main.async {
                        strongSelf.setShortlistButton()
                        strongSelf.showFavouriteView(isAddedToFavourites: true)
                    }
                    break
                case let .error(error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                    break
                case let .deffinedError(error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                    break
                }
            })
        }
    }

    @IBAction func seeAccountsButton(_: AnyObject) {
        // will open web view
        if let url = self.company?.companyUrl, let navCtrl = self.navigationController {
            CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navCtrl, contentType: ContentType.company, url: url)
        }
    }

    @IBAction func closeButton(_: AnyObject) {
        self.backgroundPopoverView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func shareButton(_: AnyObject) {
        // share link with other apps
        let socialShareData = SocialShareItemSource()
        socialShareData.company = self.company
        let activityViewController = UIActivityViewController(activityItems: [socialShareData], applicationActivities: nil)
        let excludeActivities = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.copyToPasteboard,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.airDrop,
            UIActivityType.openInIBooks,
        ]
        activityViewController.excludedActivityTypes = excludeActivities

        self.navigationController?.present(activityViewController, animated: true, completion: nil)
    }

    
    
    @IBAction func applyButton(_: AnyObject) {
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }

        let interestSet = InterestDBOperations.sharedInstance.interestsForCurrentUser()
        let interestList = [Interest](interestSet)
        if self.placement != nil {
            // placement is already created
            // placement in progress
            // update placement call
            CustomNavigationHelper.sharedInstance.presentCoverLetterController(parentCtrl: self, currentCompany: company!)
        } else {
            // new placement
            // create placement call
            guard let company = self.company else {
                return
            }

            var placement = Placement(companyUuid: company.uuid, interestsList: interestList, status: .inProgress)
            MessageHandler.sharedInstance.showLoadingOverlay(self.view)
            PlacementService.sharedInstance.createPlacement(placement: placement, postCompleted: {
                [weak self]
                _, result in
                MessageHandler.sharedInstance.hideLoadingOverlay()
                guard let strongSelf = self else {
                    return
                }
                switch result
                {
                case let .value(boxed):
                    // update in db
                    // create new placement in progress
                    placement.placementUuid = boxed.value
                    strongSelf.placement = placement
                    PlacementDBOperations.sharedInstance.savePlacemnt(placement: placement)
                    DispatchQueue.main.async {
                        strongSelf.applyButton.setTitle(NSLocalizedString("Finish Application", comment: ""), for: .normal)
                        let applyText = NSLocalizedString("Finish Application", comment: "")
                        strongSelf.applyButton.setBackgroundColor(color: UIColor(netHex: Colors.orangeNormal), forUIControlState: .normal)
                        strongSelf.applyButton.setBackgroundColor(color: UIColor(netHex: Colors.orangeActive), forUIControlState: .highlighted)
                        strongSelf.applyButton.setAttributedTitle(NSAttributedString(string: applyText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white]), for: .normal)
                    }

                    if UIApplication.shared.isRegisteredForRemoteNotifications {
                        CustomNavigationHelper.sharedInstance.presentCoverLetterController(parentCtrl: strongSelf, currentCompany: company)
                    } else {
                        CustomNavigationHelper.sharedInstance.showNotificationPopover(parentCtrl: strongSelf, currentCompany: company)
                    }
                    break
                case let .error(error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                    break
                case let .deffinedError(error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                    break
                }
            })
        }
    }
}

// MARK: - appearance
extension CompanyDetailsViewController {
    func setupAppearance() {
        setupButtons()
        setupLabels()
        setupTextView()
        setupImageView()
        self.view.backgroundColor = UIColor.clear
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.isUserInteractionEnabled = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableViewHeight.constant = self.getTableViewHeight()
    }

    func setupButtons() {
        guard let company = self.company else {
            return
        }
        applyButton.layer.masksToBounds = true

        var applyText: String = ""
        if let placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: company.uuid) {
            self.placement = placement
            // placement is created
            switch placement.status
            {
            case .inProgress:
                applyText = NSLocalizedString("Finish Application", comment: "")
                applyButton.setBackgroundColor(color: UIColor(netHex: Colors.orangeNormal), forUIControlState: .normal)
                applyButton.setBackgroundColor(color: UIColor(netHex: Colors.orangeActive), forUIControlState: .highlighted)
                break
            default:
                // applied
                applyText = NSLocalizedString("Applied", comment: "")
                applyButton.backgroundColor = UIColor(netHex: Colors.mediumGreen).withAlphaComponent(0.5)
                applyButton.isUserInteractionEnabled = false
                break
            }
        } else {
            // no placement was create
            // show apply button
            applyText = NSLocalizedString("Apply", comment: "")
            applyButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
            applyButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        }
        applyButton.layer.cornerRadius = 10
        applyButton.setAttributedTitle(NSAttributedString(string: applyText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white]), for: .normal)
        applyButton.setTitleColor(UIColor.white, for: .normal)
        applyButton.setTitleColor(UIColor.white, for: .highlighted)

        seeAcountsButton.layer.cornerRadius = 10
        seeAcountsButton.backgroundColor = UIColor(netHex: Colors.normalGray)
        let accountsText = NSLocalizedString("See accounts and who you know", comment: "")
        seeAcountsButton.setAttributedTitle(NSAttributedString(string: accountsText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black]), for: .normal)

        closeButton.setImage(UIImage(named: "closeButton"), for: .normal)
        shareButton.setImage(UIImage(named: "shareButton"), for: .normal)

        closeButton.tintColor = UIColor.black
        shareButton.tintColor = UIColor.black

        // shortlist
        shortlistButton.backgroundColor = UIColor(netHex: Colors.normalGray)
        shortlistButton.layer.cornerRadius = 10

        setShortlistButton()
    }

    func setShortlistButton() {
        guard let company = self.company else {
            return
        }

        shortlist = ShortlistDBOperations.sharedInstance.getShortlistForCurrentUser()
        if shortlist.contains(where: { $0.companyUuid == company.uuid }) {
            // the company is shortlisted
            shortlistButton.setImage(UIImage(named: "shortlist"), for: .normal)
        } else {
            // the comapny isn't shortlisted
            shortlistButton.setImage(UIImage(named: "unshortlist"), for: .normal)
        }
    }

    func setupLabels() {
        guard let company = self.company else {
            return
        }

        firmNameLabel.attributedText = NSAttributedString(string: company.name, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor.black])
    }

    func setupTextView() {
        guard let company = self.company else {
            return
        }

        firmDescriptionTextView.attributedText = NSAttributedString(string: company.summary, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black])
        firmDescriptionTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 0, height: 0), animated: false)
        firmDescriptionTextView.isEditable = false
    }

    func setupImageView() {
        guard let company = self.company else {
            return
        }
        self.firmLogoImage.image = UIImage(named: "DefaultLogo")
        if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
            ImageService.sharedInstance.getImage(url: url, completed: {
                [weak self]
                succeeded, image in
                DispatchQueue.main.async {
                    if succeeded && image != nil {
                        if let strongSelf = self {
                            strongSelf.firmLogoImage.image = image!
                        }
                    }
                }
            })
        }
    }
    
    func showFavouriteView(isAddedToFavourites: Bool) {
       // if popupView.superview != nil {
            popupView.alpha = 0.0
            popupView.removeFromSuperview()
            popupView = UIView()
     //   }
        var popupText = ""
        if isAddedToFavourites {
            popupText = NSLocalizedString("Added to Favourites", comment: "")
        } else {
            popupText = NSLocalizedString("Removed from Favourites", comment: "")
        }
        
        let sizeOfText = getSizeOfText(text: popupText)
        popupView.frame = CGRect(x: 10, y: shortlistButton.frame.origin.y - (sizeOfText.height + 30), width: sizeOfText.width + 10, height: 37)
        let textLabel = UILabel(frame: CGRect(x: 5, y: (30 - (sizeOfText.height + 10)) / 2, width: sizeOfText.width, height: sizeOfText.height + 10))
        textLabel.attributedText = NSAttributedString(string: popupText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor.white])
        textLabel.textAlignment = .center
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: sizeOfText.width + 10 , height: 37))
        imageView.image = UIImage(named: "popup")
        
        popupView.addSubview(imageView)
        popupView.addSubview(textLabel)
        self.view.addSubview(popupView)
        popupView.bringSubview(toFront: self.tableView)
        popupView.alpha = 0.0
        
        popupView.center = CGPoint(x: shortlistButton.center.x, y: popupView.center.y)
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.popupView.alpha = 1.0
        }) { (completed) in
            if completed {
                UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseInOut, animations: {
                    self.popupView.alpha = 0.0
                }, completion: { (completed) in
                    if completed {
                        self.popupView.removeFromSuperview()
                    }
                })
            }
        }
    }
    
    func getSizeOfText(text: String) -> CGSize {
        let textString = text as NSString
        let attributes = [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerTextSize, weight: UIFont.Weight.semibold)]
        let rect = textString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return CGSize(width: rect.width, height: round(rect.height))
    }
}

// MARK: - UITableViewDelegate
extension CompanyDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    private func numberOfSectionsInTableView(tableView _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.getNumberOfCells()
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.getTableViewCell(indexPath: indexPath)
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.getHeightOfRow(index: indexPath.row)
    }
}

// MARK: - helpers
extension CompanyDetailsViewController {
    func getNumberOfCells() -> Int {
        guard let company = self.company else {
            return 0
        }
        var numberOfCells: Int = 0
        if !(company.industry.isEmpty) {
            numberOfCells += 1
        }
        if company.rating != 0 && company.rating.round() != 0 {
            numberOfCells += 1
        }
        if company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0 {
            numberOfCells += 1
        }
        return numberOfCells
    }

    func getHeightOfRow(index: Int) -> CGFloat {
        guard let company = self.company else {
            return 0
        }
        switch index
        {
        case 0:
            if !company.industry.isEmpty {
                // industry cell
                return 30
            } else if company.rating != 0 && company.rating.round() != 0 {
                // rating cell
                return 46
            } else if company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0 {
                return 80
            }
            return 0
        case 1:
            if company.rating != 0 && company.rating.round() != 0 && !company.industry.isEmpty {
                // rating cell
                return 30
            } else if company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0 {
                return 80
            }
            return 0
        default:
            if (company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0) && !company.industry.isEmpty && company.rating != 0 {
                return 80
            }
            return 0
        }
    }

    func getTableViewHeight() -> CGFloat {
        let numberOfCells = self.getNumberOfCells()
        if numberOfCells == 0 {
            return 0
        }
        var tableViewHeight: CGFloat = 0
        for nr in 0 ... numberOfCells - 1 {
            tableViewHeight += self.getHeightOfRow(index: nr)
        }
        return tableViewHeight
    }

    func getTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let company = self.company else {
            return UITableViewCell()
        }
        switch indexPath.row
        {
        case 0:
            if !company.industry.isEmpty {
                // industry cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: IndustryCellIdentifier, for: indexPath) as? IndustryTableViewCell else {
                    return UITableViewCell()
                }
                cell.industryLabel.attributedText = NSAttributedString(string: company.industry, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.light), NSAttributedStringKey.foregroundColor: UIColor.black])
                return cell
            } else if company.rating != 0 && company.rating.round() != 0 {
                // rating cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RatingCellIdentifier, for: indexPath) as? RatingTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupStars(rating: company.rating)
                cell.starsLabel.attributedText = NSAttributedString(string: String(company.rating), attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerVerySmallTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])
                return cell
            } else if company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherCellIdentifier, for: indexPath) as? CompanyOtherTableViewCell else {
                    return UITableViewCell()
                }
                cell.company = self.company
                return cell
            }
            return UITableViewCell()
        case 1:
            if company.rating != 0 && company.rating.round() != 0 && !company.industry.isEmpty {
                // rating cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RatingCellIdentifier, for: indexPath) as? RatingTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupStars(rating: company.rating)
                cell.starsLabel.attributedText = NSAttributedString(string: String(company.rating), attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerVerySmallTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])
                return cell
            } else if company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherCellIdentifier, for: indexPath as IndexPath) as? CompanyOtherTableViewCell else {
                    return UITableViewCell()
                }
                cell.company = self.company
                return cell
            }
            return UITableViewCell()
        default:
            if (company.employeeCount != 0 || company.turnover != 0 || company.turnoverGrowth != 0) && !company.industry.isEmpty && company.rating != 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OtherCellIdentifier, for: indexPath as IndexPath) as? CompanyOtherTableViewCell else {
                    return UITableViewCell()
                }
                cell.company = self.company
                return cell
            }
            return UITableViewCell()
        }
    }
}

extension CompanyDetailsViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView()
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        view.image = UIImage(named: "markerIcon")
        return view
    }
    
    func setupMap() {
        let location = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
        tableView.topAnchor.constraint(equalTo: mapView.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: mapView.widthAnchor).isActive = true
        mapView.centerCoordinate = location
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = company.name
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        let adjustedRegion = mapView.regionThatFits(region)
        mapView.setRegion(adjustedRegion, animated: false)
        self.mapView.showsUserLocation = true
        mapView.delegate = self
    }
}


