//
//  TimelineViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 15/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Reachability

class TimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPlacementsBackgroundView: UIView!
    @IBOutlet weak var noPlacementsTitleLabel: UILabel!
    @IBOutlet weak var noPlacementsInfoLabel: UILabel!

    var userPlacements: [F4STimelinePlacement] = [] {
        didSet {
            if userPlacements.count == 0 {
                self.noPlacementsBackgroundView.isHidden = false
            } else {
                self.noPlacementsBackgroundView.isHidden = true
            }
        }
    }

    var companies: [Company] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    fileprivate let timelineCellIdentifier = "timelineEntryIdentifier"
    var threadUuid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        adjustNavigationBar()
        F4SUserStatusService.shared.beginStatusUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllPlacementsForUser()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return skin?.navigationBarSkin.statusbarMode == .light ? .lightContent : .default
    }
    
    lazy var placementService: F4SPlacementService = {
        return F4SPlacementService()
    }()
}

// MARK: - API Calls
extension TimelineViewController {
    
    func getAllPlacementsForUser() {
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans && userPlacements.isEmpty {
                MessageHandler.sharedInstance.display("Placements aren't loading at the moment. Please ensure you have an internet connection", parentCtrl: self)
                return
            }
        }
        
        if userPlacements.isEmpty {
            MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        }
        placementService.getAllPlacementsForUser { [weak self] (result) in
            guard let strongSelf = self else { return }
            if strongSelf.userPlacements.isEmpty {
                 MessageHandler.sharedInstance.hideLoadingOverlay()
            }
            DispatchQueue.main.async {
                switch result {
                case .error(let error):
                    if error.retry && !strongSelf.userPlacements.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5.0, execute: {
                            strongSelf.getAllPlacementsForUser()
                        })
                    } else {
                         MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: strongSelf.getAllPlacementsForUser)
                    }
                case .success(let placements):
                    strongSelf.updatePlacements(placements: placements)
                }
            }
        }
    }
    
    func updatePlacements(placements: [F4STimelinePlacement]) {
        if placements.sorted(by: {
            $0.placementUuid! > $1.placementUuid!
        }) == self.userPlacements.sorted(by: {
            $0.placementUuid! > $1.placementUuid!
        }) {
            return
        }
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        defer {
            MessageHandler.sharedInstance.hideLoadingOverlay()
        }
        userPlacements = placements.sorted(by: sortPlacementsByLatestMessage)
        let companyUuids = userPlacements.map({ $0.companyUuid })
        getCompaniesWithUuids(uuid: companyUuids)
        let unreadCount = userPlacements.filter { (placement) -> Bool in
            if placement.isRead == false {
                return true
            }
            return false
        }.count
        (tabBarController as? CustomTabBarViewController)?.configureTimelineTabBarWithCount(count: unreadCount)
    }

    func getCompaniesWithUuids(uuid: [String?]) {
        guard let comapaniesUuid = uuid as? [String] else {
            return
        }

        DatabaseOperations.sharedInstance.getCompanies(withUuid: comapaniesUuid, completed: {
            [weak self]
            companies in
            guard let strongSelf = self else {
                return
            }
            strongSelf.companies = companies
            // open from notification -> open message ctrl with thread uuid
            if let threadUuid = strongSelf.threadUuid, let placement = strongSelf.userPlacements.filter({ $0.threadUuid == threadUuid }).first {
                if let company = strongSelf.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first {
                    strongSelf.threadUuid = nil
                    CustomNavigationHelper.sharedInstance.pushMessageController(parentCtrl: strongSelf, threadUuid: threadUuid, company: company, placements: strongSelf.userPlacements, companies: strongSelf.companies)
                }
            }
        })
    }

    func sortPlacementsByLatestMessage(placement1: F4STimelinePlacement, placement2: F4STimelinePlacement) -> Bool {
        guard let message1 = placement1.latestMessage, let message2 = placement2.latestMessage else {
            return placement2.latestMessage == nil ? true : false
        }
        let isRead1 = placement1.isRead ?? true
        let isRead2 = placement2.isRead ?? true
        if isRead1 && !isRead2 { return false }
        if isRead2 && !isRead1 { return true }
        if message2.dateTime == nil { return false }
        if message1.dateTime == nil { return true }
        return message1.dateTime! > message2.dateTime!
    }
}

// MARK: - UI Setup
extension TimelineViewController {

    func adjustNavigationBar() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "MenuButton")?.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(TimelineViewController.menuButtonTapped))
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("Timeline", comment: "")
        styleNavigationController()
    }

    func setupBackgroundView() {
        let titleStr = NSLocalizedString("No applications yet", comment: "")
        let infoStr = NSLocalizedString("You can use the map to find and apply for a placement. Once you have submitted your application, your messages with the company will appear here.", comment: "")

        self.noPlacementsTitleLabel.attributedText = NSAttributedString(string: titleStr, attributes: [
            NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold),
        ])
        self.noPlacementsInfoLabel.attributedText = NSAttributedString(string: infoStr, attributes: [
            NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular),
        ])
        self.noPlacementsBackgroundView.isHidden = true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TimelineViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.companies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: timelineCellIdentifier, for: indexPath) as? TimelineEntryTableViewCell else {
            return UITableViewCell()
        }
        let placement = self.userPlacements[indexPath.row]
        if let company = self.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first {
            cell.companyImageView.image = UIImage(named: "DefaultLogo")
            cell.companyTitleLabel.attributedText = NSAttributedString(string: company.name, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize,weight: UIFont.Weight.medium),NSAttributedStringKey.foregroundColor: UIColor.black,])
            cell.companyImageView.layer.cornerRadius = cell.companyImageView.bounds.height / 2
            cell.companyImageView.image = UIImage(named: "DefaultLogo")
            if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
                F4SImageService.sharedInstance.getImage(url: url, completion: {
                    image in
                    if image != nil {
                        cell.companyImageView.image = image!
                    }
                })
            }

            cell.unreadMessageDotView.layer.cornerRadius = cell.unreadMessageDotView.bounds.height / 2
            cell.unreadMessageDotView.backgroundColor = UIColor(netHex: Colors.orangeYellow)

            guard let latestMessage = placement.latestMessage else {
                // TODO: Fill out with suitable null values
                return cell
            }
            if placement.isRead == true || latestMessage.content.isEmpty == true {
                
                cell.unreadMessageDotView.isHidden = true
                cell.latestMessageLabel.attributedText = NSAttributedString(
                    string: latestMessage.content,
                    attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize,weight: UIFont.Weight.light),NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.warmGrey)])

                cell.dateTimeLatestMessageLabel.attributedText = NSAttributedString(
                    string: latestMessage.relativeDateTime ?? "",
                    attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize,weight: UIFont.Weight.light),NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])
            } else {
                cell.unreadMessageDotView.isHidden = false
                cell.latestMessageLabel.attributedText = NSAttributedString(
                    string: latestMessage.content,
                    attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize,                                                                          weight: UIFont.Weight.semibold),NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.black)])

                cell.dateTimeLatestMessageLabel.attributedText = NSAttributedString(
                    string: latestMessage.relativeDateTime ?? "",
                    attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.orangeYellow)])
            }
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placement = self.userPlacements[indexPath.row]
        if let company = self.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first {
            CustomNavigationHelper.sharedInstance.pushMessageController(parentCtrl: self, threadUuid: placement.threadUuid, company: company, placements: self.userPlacements, companies: self.companies)
        }
    }

    func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}

// MARK: - user interaction
extension TimelineViewController {
    @objc func menuButtonTapped() {
        CustomNavigationHelper.sharedInstance.toggleMenu()
    }

    func goToMessageViewCtrl() {
        // open from notification -> open message ctrl with thread uuid
        if let placement = self.userPlacements.filter({ $0.threadUuid == threadUuid }).first {
            if let company = self.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first {
                self.threadUuid = nil
                CustomNavigationHelper.sharedInstance.pushMessageController(parentCtrl: self, threadUuid: placement.threadUuid!, company: company, placements: self.userPlacements, companies: self.companies)
            }
        }
    }
}
