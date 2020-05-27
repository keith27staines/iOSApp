//
//  CustomMenuViewController.swift
//  f4s-workexperience
//
//  Created by Freshbyte on 12/8/14.
//  Copyright (c) 2014 Freshbyte. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderOnboardingUseCase

fileprivate enum DrawerSection: Int {
    case WelcomeSection
    case NavigationSection
    case EnvironmentSection
}

fileprivate enum NavigationSectionRow : Int {
    case about
    case faq
    case terms
    case privacyPolicy
    static var allRows: [NavigationSectionRow] {
        return [.about, .faq, .terms, .privacyPolicy]
    }
    
    var title: String {
        switch self
        {
        case .about:
            return NSLocalizedString("About Workfinder", comment: "Menu item providing information about Workfinder")
        case .faq:
            return NSLocalizedString("FAQs", comment: "Menu item providing access to frequently asked questions")
        case .terms:
            return NSLocalizedString("T&Cs", comment: "Menu item providing access to terms and conditions")
        case .privacyPolicy:
            return NSLocalizedString("Privacy policy", comment: "Menu item providing access to the privacy policy")
        }
    }
}

class CustomMenuViewController: BaseMenuViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var tableView: UITableView!
    let normalCellHeight: CGFloat = 60
    let welcomeCellHeight: CGFloat = 100
    var secondLoad = false
    weak var tabBarCoordinator: TabBarCoordinator!
    weak var log: F4SAnalyticsAndDebugging?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setupTableView()
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
        return 4
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = DrawerSection(rawValue: section) else { return 0 }
        switch section {
        case .WelcomeSection:
            return 1
        case .NavigationSection:
            return NavigationSectionRow.allRows.count
        case .EnvironmentSection:
            return 1
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
                let logos: [UIImage?] = [workfinderLogo]
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
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            return cell
        case .EnvironmentSection:
            guard let _ = NavigationSectionRow(rawValue: indexPath.row), let cell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerTableViewCell") as? SideDrawerTableViewCell else {
                return UITableViewCell()
            }
            cell.textLabel?.text = getEnvironmentText()
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = DrawerSection(rawValue: section) else { return nil }
        switch section {
        case .WelcomeSection:
            return nil
        case .NavigationSection:
            return nil
        case .EnvironmentSection:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideDrawerTableViewCell") as? SideDrawerTableViewCell,
            let section = DrawerSection(rawValue: section) else { return nil }
        cell.lineImageView.isHidden = false
        switch section {
        case .WelcomeSection:
            return nil
        case .NavigationSection:
            cell.textLabel?.text = ""
            cell.lineImageView.isHidden = true
            return cell
        case .EnvironmentSection:
            return nil
        }
    }
    
    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = DrawerSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .WelcomeSection: return 0
        case .NavigationSection: return 0
        case .EnvironmentSection: return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = DrawerSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .WelcomeSection: return 0
        case .NavigationSection: return 70
        case .EnvironmentSection: return 0
        }
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = DrawerSection(rawValue: indexPath.section) else { return normalCellHeight }
        switch section {
        case .WelcomeSection: return welcomeCellHeight
        case .NavigationSection: return normalCellHeight
        case .EnvironmentSection: return normalCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let drawerSection = DrawerSection(rawValue: indexPath.section) else { return }
        switch drawerSection {
        case DrawerSection.WelcomeSection:
            break
        case DrawerSection.NavigationSection:
            guard
                let navigationRow = NavigationSectionRow(rawValue: indexPath.row)
                else { return }
            let contentType: WorkfinderContentType
            switch navigationRow
            {
            case .about:
                contentType = .about
            case .faq:
                contentType = .faqs
            case .terms:
                contentType = .terms
            case .privacyPolicy:
                contentType = .privacyPolicy
            }
            switch contentType.openingMode {
            case .inWorkfinder:
                let vc = WebViewController(
                    url: contentType.url,
                    showNavigationButtons: true,
                    delegate: self)
                present(vc, animated: true, completion: nil)
            case .inBrowser:
                UIApplication.shared.open(contentType.url, options: [:], completionHandler: nil)
            }

        case .EnvironmentSection:
            break
        }

        tableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .none)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

// adjust text appereance
extension CustomMenuViewController {
    
    func getEnvironmentText() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        
        var versionString = version
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionString = versionString + " build \(build)"
        }
        var environmentString: String
        switch Config.environmentName {
        case "STAGING":
            environmentString = "STAGING"
        case "PRODUCTION":
            environmentString = ""
        default:
            assertionFailure("Unexpected environment target")
            environmentString = "ENV ?"
        }
        
        return "version " + versionString + " " + environmentString.lowercased() + " | apns =" + Config.apns
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

extension CustomMenuViewController: WebViewControllerDelegate {
    func webViewControllerDidFinish(_ vc: WebViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    
}
