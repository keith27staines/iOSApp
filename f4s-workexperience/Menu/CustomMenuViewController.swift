//
//  CustomMenuViewController.swift
//  f4s-workexperience
//
//  Created by Freshbyte on 12/8/14.
//  Copyright (c) 2014 Freshbyte. All rights reserved.
//

import UIKit

fileprivate enum DrawerSection: Int {
    case WelcomeSection
    case NavigationSection
    case LogoutSection
}

fileprivate enum NavigationSectionRow : Int {
    case about
    case faq
    case terms
    static var allRows: [NavigationSectionRow] {
        return [.about, .faq, .terms]
    }
    
    var title: String {
        switch self
        {
        case .about:
            return NSLocalizedString("About", comment: "Menu item providing information about Workfinder")
        case .faq:
            return NSLocalizedString("FAQs", comment: "Menu item providing access to frequently asked questions")
        case .terms:
            return NSLocalizedString("T&Cs + Privacy Policy", comment: "Menu item providing access to terms and conditions")
        }
    }
}

class CustomMenuViewController: BaseMenuViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var tableView: UITableView!
    let normalCellHeight: CGFloat = 60
    let welcomeCellHeight: CGFloat = 100
    var secondLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setupTableView()
        setupLabels()
        applyStyle()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.bounces = false
        tableView.register(UINib(nibName: "MenuHeaderCell", bundle: nil), forCellReuseIdentifier: "MenuHeaderCell")
        tableView.register(SideDrawerLogosTableviewCell.self, forCellReuseIdentifier: "SideDrawerLogosTableviewCell")
        tableView.register(SideDrawerTableViewCell.self, forCellReuseIdentifier: "SideDrawerTableViewCell")
        view.addSubview(self.tableView)
        if #available(iOS 11.0, *) {
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            tableView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: 0).isActive = true
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        secondLoad = true
        tableView.backgroundColor = UIColor.clear
        tableView.reloadData()
        applyStyle()
    }

    func applyStyle() {
        self.view.backgroundColor = skin?.navigationBarSkin.barTintColor.uiColor
         setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func contentSizeDidChange(size _: String) {
        self.tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = DrawerSection(rawValue: section) else { return 0 }
        switch section {
        case .WelcomeSection:
            return 1
        case .NavigationSection:
            return NavigationSectionRow.allRows.count
        case .LogoutSection:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = DrawerSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch section {
        case .WelcomeSection:
            switch indexPath.row {
            case 0:
                guard let logoCell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerLogosTableviewCell") as? SideDrawerLogosTableviewCell else {
                    return UITableViewCell()
                }
                let workfinderLogo = UIImage(named: "logo2")
                let partnerLogo = F4SPartnersModel.sharedInstance.selectedPartner?.image
                let logos: [UIImage?] = [workfinderLogo, partnerLogo]
                logoCell.setLogos(logos)
                logoCell.isUserInteractionEnabled = false
                logoCell.lineImageView.isHidden = true
                return logoCell
            default:
                return UITableViewCell()
            }

        case .NavigationSection:
            guard let row = NavigationSectionRow(rawValue: indexPath.row), let cell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerTableViewCell") as? SideDrawerTableViewCell else {
                return UITableViewCell()
            }
            cell.textLabel?.text = row.title
            return cell
        case .LogoutSection:
            return UITableViewCell()
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = DrawerSection(rawValue: indexPath.section) else { return normalCellHeight }
        switch section {
        case .WelcomeSection:
            return welcomeCellHeight
        case .NavigationSection:
            return normalCellHeight
        case .LogoutSection:
            return normalCellHeight
        }
    }
    
    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 30 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let drawerSection = DrawerSection(rawValue: indexPath.section) else { return }
        switch drawerSection {
        case DrawerSection.WelcomeSection:
            break
        case DrawerSection.NavigationSection:
            if let navigCtrl = self.navigationController {
                guard let navigationRow = NavigationSectionRow(rawValue: indexPath.row) else {
                    return
                }
                let navigationHelper = TabBarCoordinator.sharedInstance
                switch navigationRow
                {
                case .about:
                    navigationHelper!.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.about)
                case .faq:
                    navigationHelper!.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.faq)
                case .terms:
                    navigationHelper!.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.terms)
                }
            }
        case .LogoutSection:
            break
        }

        tableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .none)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

// adjust text appereance
extension CustomMenuViewController {

    func setupLabels() {
        let label = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            var versionString = version
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                versionString = versionString + " build \(build)"
            }
            var environmentString: String
            switch Config.ENVIRONMENT {
            case "STAGING":
                environmentString = "STAGING"
            case "PRODUCTION":
                environmentString = ""
            default:
                assertionFailure("Unexpected environment target")
                environmentString = "ENV ?"
            }
            label.text = "version " + versionString + " " + environmentString.lowercased() + " | apns =" + Config.apns
        }
        label.frame = CGRect(x: 5, y: self.view.frame.size.height - 55, width: 31, height: 14)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        self.view.addSubview(label)
    }
}
extension CustomMenuViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
