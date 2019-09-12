//
//  FavouriteViewController.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 2/8/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import Foundation
import UIKit
import WorkfinderCommon
import WorkfinderUI

class FavouriteViewController: UIViewController {
    
    weak var coordinator: FavouritesCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noFavouritesBackgroundView: UIView!
    @IBOutlet weak var noFavouritesTitleLabel: UILabel!
    @IBOutlet weak var noFavouritesMessageLabel: UILabel!
    
    var placementsRepository: F4SPlacementRepositoryProtocol!
    var favouritesRepository: F4SFavouritesRepositoryProtocol!
    var companyRepository: F4SCompanyRepositoryProtocol!
    
    var favouriteList: [Shortlist] = [] {
        didSet {
            if favouriteList.count == 0 {
                self.noFavouritesBackgroundView.isHidden = false
            } else {
                self.noFavouritesBackgroundView.isHidden = true
            }
        }
    }
    var placementList: [F4SPlacement] = []
    var companies: [Company] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    fileprivate let FavouriteTableViewCellIndentifier = "FavouriteTableViewCellIndentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.clear
        setupBackgroundView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustNavigationBar()
        loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
//MARK: - UI Setup
extension FavouriteViewController {
    
    func adjustNavigationBar() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "MenuButton")?.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(menuButtonTapped))
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("Favourites", comment: "")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        styleNavigationController()
    }
    
    func setupBackgroundView() {
        let titleStr = NSLocalizedString("No favourites yet", comment: "")
        let infoStr = NSLocalizedString("Once you have favourited a company it will appear here.", comment: "")
        
        noFavouritesTitleLabel.attributedText = NSAttributedString(string: titleStr, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold)])
        noFavouritesMessageLabel.attributedText = NSAttributedString(string: infoStr, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.pinkishGrey),
            NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular)])
        noFavouritesBackgroundView.isHidden = true
    }
}

//MARK: - get data
extension FavouriteViewController {
    
    func loadData() {
        favouriteList = favouritesRepository.loadFavourites()
        favouriteList.sort(by: { $0.date > $1.date })
        placementList = placementsRepository.load()
        let companyUuids = favouriteList.map({ $0.companyUuid })
        getCompaniesWithUuids(uuid: companyUuids)
    }
    
    func getCompaniesWithUuids(uuid: [String?]) {
        guard let comapanyUuids = uuid as? [String] else {
            return
        }
        companyRepository.load(companyUuids: comapanyUuids) { [weak self] (companies) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.companies = companies
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteTableViewCellIndentifier) as? FavouriteTableViewCell else {
            return UITableViewCell()
        }
        
        let favourite = favouriteList[indexPath.row]
        if let company = self.companies.filter({ $0.uuid == favourite.companyUuid.dehyphenated }).first {
            cell.companyTitleLabel.attributedText = NSAttributedString(
                string: company.name,
                attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize,weight: UIFont.Weight.medium),NSAttributedString.Key.foregroundColor: UIColor.black])
            cell.companyImageView.layer.cornerRadius = cell.companyImageView.bounds.height / 2
            cell.companyImageView.load(urlString: company.logoUrl, defaultImage: Company.defaultLogo)
            cell.companyIndustryLabel.attributedText = NSAttributedString(
                string: company.industry,
                attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallTextSize,weight: UIFont.Weight.light), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.black)])
        }
        if let placement = placementList.filter({ $0.companyUuid == favourite.companyUuid.dehyphenated }).first, placement.status == .applied {
            cell.companyStatusLabel.isHidden = false
            cell.companyStatusLabel.attributedText = NSAttributedString(
                string: NSLocalizedString("Applied", comment: ""),
                attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.biggerVerySmallTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.white)])
            cell.companyStatusLabel.backgroundColor = UIColor(netHex: Colors.mediumGreen)
            cell.companyStatusLabel.layer.cornerRadius = 5
            cell.companyStatusLabel.layer.masksToBounds = true
        } else {
            cell.companyStatusLabel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favourite = favouriteList[indexPath.row]
        let company = self.companies.filter({ $0.uuid == favourite.companyUuid.dehyphenated }).first
        coordinator?.showDetail(company: company)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let text = NSLocalizedString("You can favourite a maximum of \(__maximumNumberOfFavourites) companies.", comment: "")
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.pinkishGrey)])
        label.sizeToFit()
        return label
    }
}

// MARK: - user interaction
extension FavouriteViewController {
    @objc func menuButtonTapped() {
        (parent as? TabBarCoordinatorProtocol)?.toggleMenu(completion: nil)
    }
}
