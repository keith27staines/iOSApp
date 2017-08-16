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
        self.view.backgroundColor = UIColor(netHex: Colors.azure)
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
            return 5

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
                let image: UIImage = UIImage(named: "logo2")!
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 30, y: 30, width: 90, height: 90)
                cell.addSubview(imageView)
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
                if secondLoad {
                    let lineImage = UIImageView()
                    lineImage.frame = CGRect(x: 30, y: cell.bounds.minY, width: cell.frame.size.width, height: cell.frame.size.height)
                    lineImage.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                    cell.addSubview(lineImage)
                }
            case 2:
                cell.textLabel?.attributedText = setNavigationSection(index: indexPath.row)
            case 3:
                if secondLoad {
                    let lineImage = UIImageView()
                    lineImage.frame = CGRect(x: 30, y: cell.bounds.maxY, width: cell.frame.size.width, height: cell.frame.size.height)
                    lineImage.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                    cell.addSubview(lineImage)
                }
            case 4:
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
            case 1:
                return smallCellHeight
            case 3:
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

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case DrawerSection.WelcomeSection.rawValue:
            break
        case DrawerSection.NavigationSection.rawValue:
            if let navigCtrl = self.navigationController {
                switch indexPath.row
                {
                case 0:
                    CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navigCtrl, contentType: ContentType.about)
                case 2:
                    CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navigCtrl, contentType: ContentType.faq)
                case 4:
                    CustomNavigationHelper.sharedInstance.moveToContentViewController(navCtrl: navigCtrl, contentType: ContentType.terms)
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
            text = NSLocalizedString("About", comment: "")
        case 2:
            text = NSLocalizedString("FAQs", comment: "")
        case 4:
            text = NSLocalizedString("T&Cs + Privacy Policy", comment: "")
        default:
            break
        }
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor(netHex: Colors.white), NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(Style.biggerLargeTextSize), weight: UIFontWeightRegular)])

        return attributedText
    }

    func setupLabels() {
        let label = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "v" + version
        }
        label.frame = CGRect(x: 30, y: self.view.frame.size.height - 55, width: 31, height: 14)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        self.view.addSubview(label)
    }
}
