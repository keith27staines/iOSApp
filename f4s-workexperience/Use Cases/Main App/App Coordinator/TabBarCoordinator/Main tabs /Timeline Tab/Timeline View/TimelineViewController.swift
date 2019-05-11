//
//  TimelineViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 15/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Reachability
import WorkfinderCommon

class TimelineViewController: UIViewController {
    
    weak var coordinator: TimelineCoordinator?

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
                if footerView == nil {
                    footerView = UIView()
                    tableView.tableFooterView = footerView
                }
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
    
    var footerView: UIView?

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
                sharedUserMessageHandler.displayAlertFor("Placements aren't loading at the moment. Please ensure you have an internet connection", parentCtrl: self)
                return
            }
        }
        
        if userPlacements.isEmpty {
            sharedUserMessageHandler.showLoadingOverlay(self.view)
        }
        placementService.getAllPlacementsForUser { [weak self] (result) in
            guard let strongSelf = self else { return }
            if strongSelf.userPlacements.isEmpty {
                 sharedUserMessageHandler.hideLoadingOverlay()
            }
            DispatchQueue.main.async {
                switch result {
                case .error(let error):
                    if error.retry && !strongSelf.userPlacements.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5.0, execute: {
                            strongSelf.getAllPlacementsForUser()
                        })
                    } else {
                         sharedUserMessageHandler.display(
                            error,
                            parentCtrl: strongSelf,
                            cancelHandler: {},
                            retryHandler: strongSelf.getAllPlacementsForUser)
                    }
                case .success(let placements):
                    strongSelf.updatePlacements(placements: placements)
                }
            }
        }
    }
    
    func updatePlacements(placements: [F4STimelinePlacement]) {
        sharedUserMessageHandler.showLoadingOverlay(self.view)
        defer {
            sharedUserMessageHandler.hideLoadingOverlay()
        }
        userPlacements = placements.sorted(by: sortPlacementsByLatestMessage)
        let companyUuids = userPlacements.map({ $0.companyUuid })
        getCompaniesWithUuids(uuid: companyUuids)
        let unreadCount = userPlacements.filter { (placement) -> Bool in
            if placement.latestMessage?.isRead == false {
                return true
            }
            return false
        }.count
        (tabBarController as? TabBarViewController)?.configureTimelineTabBarWithCount(count: unreadCount)
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
                    TabBarCoordinator.sharedInstance.pushMessageController(parentCtrl: strongSelf, threadUuid: threadUuid, company: company, placements: strongSelf.userPlacements, companies: strongSelf.companies)
                }
            }
        })
    }

    func sortPlacementsByLatestMessage(placement1: F4STimelinePlacement, placement2: F4STimelinePlacement) -> Bool {
        guard let message1 = placement1.latestMessage, let message2 = placement2.latestMessage else {
            return placement2.latestMessage == nil ? true : false
        }
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        styleNavigationController()
    }

    func setupBackgroundView() {
        let titleStr = NSLocalizedString("No applications yet", comment: "")
        let infoStr = NSLocalizedString("You can use Search to find and apply for a placement. Once you have submitted your application, your messages with the company will appear here.", comment: "")

        self.noPlacementsTitleLabel.attributedText = NSAttributedString(string: titleStr, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold),
        ])
        self.noPlacementsInfoLabel.attributedText = NSAttributedString(string: infoStr, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular),
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
        let placement = self.userPlacements[indexPath.row]
        guard
            let company = self.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first,
            let cell = tableView.dequeueReusableCell(withIdentifier: timelineCellIdentifier, for: indexPath) as? TimelineEntryTableViewCell else {
            return UITableViewCell()
        }
        cell.presenter = TimelineCellViewPresenter(cell: cell, placement: placement, company: company)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placement = self.userPlacements[indexPath.row]
        if let company = self.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first {
            TabBarCoordinator.sharedInstance.pushMessageController(parentCtrl: self, threadUuid: placement.threadUuid, company: company, placements: self.userPlacements, companies: self.companies)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? TimelineEntryTableViewCell)?.presenter = nil
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
        TabBarCoordinator.sharedInstance.toggleMenu()
    }

    func goToMessageViewCtrl() {
        // open from notification -> open message ctrl with thread uuid
        if let placement = self.userPlacements.filter({ $0.threadUuid == threadUuid }).first {
            if let company = self.companies.filter({ $0.uuid == placement.companyUuid?.dehyphenated }).first {
                self.threadUuid = nil
                TabBarCoordinator.sharedInstance.pushMessageController(parentCtrl: self, threadUuid: placement.threadUuid!, company: company, placements: self.userPlacements, companies: self.companies)
            }
        }
    }
}

class TimelineCellViewPresenter {
    let warmGrey = UIColor(netHex: Colors.warmGrey)
    let black = UIColor.black
    let red = UIColor.red
    let lightWeight = UIFont.Weight.light
    let semiBold = UIFont.Weight.semibold
    let smallSize = UIFont.smallSystemFontSize
    let cell: TimelineEntryTableViewCell
    let placement: F4STimelinePlacement
    let company: Company?
    
    init(cell: TimelineEntryTableViewCell, placement: F4STimelinePlacement, company: Company) {
        self.placement = placement
        self.company = company
        self.cell = cell
    }
    
    func present() {
        prepareEmpty(cell)
        prepareWithCompany(cell: cell, company: company)
        prepareWithLatestMessage(cell: cell, message: placement.latestMessage)
    }
    
    private func prepareEmpty(_ cell: TimelineEntryTableViewCell) {
        cell.companyImageView.contentMode = .scaleAspectFit
        cell.unreadMessageDotView.layer.cornerRadius = cell.unreadMessageDotView.bounds.height / 2
        cell.companyImageView.layer.cornerRadius = cell.companyImageView.bounds.height / 2
        cell.companyTitleLabel.text = NSLocalizedString("Company data not found", comment: "")
        cell.companyImageView.image = nil
        cell.unreadMessageDotView.isHidden = true
        cell.latestMessageLabel.text = nil
        cell.dateTimeLatestMessageLabel.text = nil
    }
    
    private func prepareWithCompany(cell: TimelineEntryTableViewCell, company: Company?) {
        guard let company = company else { return }
        cell.companyTitleLabel.text = company.name.stripCompanySuffix()
        cell.companyImageView.image = UIImage(named: "DefaultLogo")
        guard !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) else { return }
        F4SImageService.sharedInstance.getImage(url: url, completion: { [weak self] image in
            guard self === cell.presenter else { return}
            guard let image = image else { return }
            cell.companyImageView.image = image
        })
    }
    
    private func prepareWithLatestMessage(cell: TimelineEntryTableViewCell, message: F4SMessage?) {
        guard let message = message else {
            cell.latestMessageLabel.text = NSLocalizedString("Draft", comment: "As in 'in preparation'")
            cell.latestMessageLabel.textColor = warmGrey
            return
        }
        cell.latestMessageLabel.text = message.content
        cell.dateTimeLatestMessageLabel.text = message.relativeDateTime ?? ""
        let isRead = message.isRead == true
        let weight = isRead ? lightWeight : semiBold
        cell.unreadMessageDotView.isHidden = isRead
        cell.latestMessageLabel.textColor = isRead ? warmGrey : black
        cell.dateTimeLatestMessageLabel.textColor = isRead ? black : red
        cell.latestMessageLabel.font = UIFont.systemFont(ofSize: smallSize, weight: weight)
    }
}
