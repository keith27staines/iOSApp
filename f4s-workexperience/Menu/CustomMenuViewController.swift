//
//  CustomMenuViewController.swift
//  f4s-workexperience
//
//  Created by Freshbyte on 12/8/14.
//  Copyright (c) 2014 Freshbyte. All rights reserved.
//

import UIKit

enum DrawerSection: Int {
    case WelcomeSection
    case NavigationSection
    case LogoutSection
}

class CustomMenuViewController: BaseMenuViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var tableView: UITableView!
    let drawerWidths: [CGFloat] = [160, 200, 240, 280, 320]
    let normalCellHeight: CGFloat = 83
    let smallCellHeight: CGFloat = 0.5
    let welcomeCellHeight: CGFloat = 150
    var secondLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + UIApplication.shared.statusBarFrame.height, width: self.view.bounds.width, height: self.view.bounds.height - UIApplication.shared.statusBarFrame.size.height)
        self.tableView = UITableView(frame: frame, style: .plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.bounces = false
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
        tableView.register(UINib(nibName: "MenuHeaderCell", bundle: nil), forCellReuseIdentifier: "MenuHeaderCell")
        switch Config.environment {
        case .staging:
            self.view.backgroundColor = WorkfinderColor.stagingGold
        case .production:
            self.view.backgroundColor = UIColor(red: 72.0/255.0, green: 38.0/255.0, blue: 127.0/255.0, alpha: 1.0)
        }

        setupLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        secondLoad = true
        self.tableView.reloadData()
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func contentSizeDidChange(size _: String) {
        self.tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case DrawerSection.WelcomeSection.rawValue:
            return 1
        case DrawerSection.NavigationSection.rawValue:
            return 7

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"

        var cell: SideDrawerTableViewCell! = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? SideDrawerTableViewCell

        if cell == nil {
            cell = SideDrawerTableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        }

        switch indexPath.section
        {
        case DrawerSection.WelcomeSection.rawValue:
            switch indexPath.row
            {
            case 0:
                let imageStack = UIStackView()
                imageStack.axis = .horizontal
                imageStack.spacing = 40
                imageStack.distribution = .fillEqually
                let image: UIImage = UIImage(named: "logo2")!
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
                imageStack.addArrangedSubview(imageView)
                if let partnerLogo = F4SPartnersModel.sharedInstance.selectedPartner?.image {
                    let partnerImage = UIImageView(image: partnerLogo)
                    partnerImage.contentMode = .scaleAspectFit
                    imageStack.addArrangedSubview(partnerImage)
                }
                imageStack.frame = CGRect(x: 30, y: 30, width: 300, height: 60)
                imageStack.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(imageStack)
                imageStack.topAnchor.constraint(equalTo: cell.topAnchor, constant: 12).isActive = true
                imageStack.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -12).isActive = true
                imageStack.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 20).isActive = true
                imageStack.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
                cell.isUserInteractionEnabled = false
            default:
                break
            }
            break
        case DrawerSection.NavigationSection.rawValue:
            switch indexPath.row {
            case 0:
                cell.textLabel?.attributedText = setNavigationSection(index: indexPath.row)
            case 1:
                addLineImage(cell: cell)
            case 2:
                cell.textLabel?.attributedText = setNavigationSection(index: indexPath.row)
            case 3:
                addLineImage(cell: cell)
            case 4:
                cell.textLabel?.attributedText = setNavigationSection(index: indexPath.row)
            case 5:
                addLineImage(cell: cell)
            case 6:
                cell.textLabel?.attributedText = setNavigationSection(index: indexPath.row)
            default:
                break
            }
            break
        default:
            break
        }
        return cell
    }
    
    func addLineImage(cell: SideDrawerTableViewCell) {
        guard secondLoad != false else {
            return
        }
        let lineImage = UIImageView()
        lineImage.frame = CGRect(x: 30, y: cell.bounds.maxY, width: cell.frame.size.width, height: cell.frame.size.height)
        lineImage.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        cell.addSubview(lineImage)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case DrawerSection.WelcomeSection.rawValue:
            return welcomeCellHeight
        case DrawerSection.NavigationSection.rawValue:
            switch indexPath.row {
            case 1,3,5:
                return smallCellHeight
            default:
                return normalCellHeight
            }
            
        case DrawerSection.LogoutSection.rawValue:
            return normalCellHeight
            
        default:
            return 0
        }
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case DrawerSection.WelcomeSection.rawValue:
            break
        case DrawerSection.NavigationSection.rawValue:
            if let navigCtrl = self.navigationController {
                switch indexPath.row
                {
                case 0:
                    CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.about)
                case 2:
                    CustomNavigationHelper.sharedInstance.navigateToRecommendations(company: nil)
                case 4:
                    CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.faq)
                case 6:
                    CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navigCtrl, contentType: F4SContentType.terms)
                default:
                    break
                }
            }
        default:
            break
        }

        tableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .none)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

// adjust text appereance
extension CustomMenuViewController {
    func setNavigationSection(index: Int) -> NSMutableAttributedString {
        var text: String = ""
        switch index
        {
        case 0:
            text = NSLocalizedString("About", comment: "Menu item providing information about Workfinder")
        case 2:
            text = NSLocalizedString("Your recommendations", comment: "Menu item offering the user recommendations")
        case 4:
            text = NSLocalizedString("FAQs", comment: "Menu item providing access to frequently asked questions")
        case 6:
            text = NSLocalizedString("T&Cs + Privacy Policy", comment: "Menu item providing access to terms and conditions")
        default:
            break
        }
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.white), NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(Style.biggerLargeTextSize), weight: UIFont.Weight.regular)])

        return attributedText
    }

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
