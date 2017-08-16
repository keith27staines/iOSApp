//
//  CustomTableViewCell.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/16/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class CompanyOtherTableViewCell: UITableViewCell {
    @IBOutlet weak var customCollectionView: UICollectionView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var firstLineView: UIView!

    fileprivate let CompanyCollectionIdentifier: String = "companyCollectionIdentifier"
    var company: Company? {
        didSet {
            self.customCollectionView.reloadData()
        }
    }

    fileprivate let thousand: Double = 1000
    fileprivate let million: Double = 1_000_000
    fileprivate let billion: Double = 1_000_000_000

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - UICollectionViewDelegate
extension CompanyOtherTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.getNumberOfCells()
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.getCellForIndexPath(indexPath: indexPath)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return CGFloat(0)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return CGFloat(0)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 102, height: collectionView.frame.size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        let screenWidth: CGFloat = collectionView.bounds.width
        let nrOfCells = self.getNumberOfCells()
        let s = CGFloat(102) * CGFloat(nrOfCells)
        let space = screenWidth - s
        return UIEdgeInsets(top: 0, left: space / 2, bottom: 0, right: space / 2)
    }
}

// MARK: - adjust appereance
extension CompanyOtherTableViewCell {
    func setupAppearance() {
        firstLineView.backgroundColor = UIColor(netHex: Colors.pinkishGrey)
        secondLineView.backgroundColor = UIColor(netHex: Colors.pinkishGrey)
    }

    func setupCollectionView() {
        customCollectionView.dataSource = self
        customCollectionView.delegate = self
        customCollectionView.backgroundColor = UIColor.clear
        customCollectionView.isUserInteractionEnabled = false
    }
}

// MARK: - helpers
extension CompanyOtherTableViewCell {
    func getNumberOfCells() -> Int {
        guard let company = self.company else {
            return 0
        }

        var numberOfCell: Int = 0
        if company.employeeCount != 0 {
            numberOfCell += 1
        }
        if company.turnover != 0 {
            numberOfCell += 1
        }
        if company.turnoverGrowth != 0 {
            numberOfCell += 1
        }
        return numberOfCell
    }

    func getCellForIndexPath(indexPath: IndexPath) -> UICollectionViewCell {
        guard let company = self.company else {
            return UICollectionViewCell()
        }

        switch indexPath.row
        {
        case 0:
            if company.employeeCount != 0 {
                guard let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionIdentifier, for: indexPath) as? CompanyCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.numberLabel.attributedText = NSAttributedString(string: self.getEmployeeString(), attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.extraLargeTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray)])
                let text = NSLocalizedString("Employees", comment: "")
                cell.textLabel.attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.verySmallTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray).withAlphaComponent(0.5)])
                return cell
            } else if company.turnover != 0 {
                guard let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionIdentifier, for: indexPath) as? CompanyCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.numberLabel.attributedText = NSAttributedString(string: self.getAnnualRevenueString(), attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.extraLargeTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray)])
                let text = NSLocalizedString("Annual revenue", comment: "")
                cell.textLabel.attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.verySmallTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray).withAlphaComponent(0.5)])
                return cell
            } else if company.turnoverGrowth != 0 {
                guard let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionIdentifier, for: indexPath) as? CompanyCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.numberLabel.attributedText = NSAttributedString(string: self.getAnnualGrowthString(), attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.extraLargeTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray)])
                let text = NSLocalizedString("Annual growth", comment: "")
                cell.textLabel.attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.verySmallTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray).withAlphaComponent(0.5)])
                return cell
            }
            return UICollectionViewCell()
        case 1:
            if company.turnover != 0 && company.employeeCount != 0 {
                guard let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionIdentifier, for: indexPath) as? CompanyCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.numberLabel.attributedText = NSAttributedString(string: self.getAnnualRevenueString(), attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.extraLargeTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray)])
                let text = NSLocalizedString("Annual revenue", comment: "")
                cell.textLabel.attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.verySmallTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray).withAlphaComponent(0.5)])
                return cell
            } else if company.turnoverGrowth != 0 {
                guard let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionIdentifier, for: indexPath) as? CompanyCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.numberLabel.attributedText = NSAttributedString(string: self.getAnnualGrowthString(), attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.extraLargeTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray)])
                let text = NSLocalizedString("Annual growth", comment: "")
                cell.textLabel.attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.verySmallTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray).withAlphaComponent(0.5)])
                return cell
            }
            return UICollectionViewCell()
        default:
            if company.turnoverGrowth != 0 && company.turnover != 0 && company.employeeCount != 0 {
                guard let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionIdentifier, for: indexPath) as? CompanyCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.numberLabel.attributedText = NSAttributedString(string: self.getAnnualGrowthString(), attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.extraLargeTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray)])
                let text = NSLocalizedString("Annual growth", comment: "")
                cell.textLabel.attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.f4sSystemFont(size: Style.verySmallTextSize, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(netHex: Colors.gray).withAlphaComponent(0.5)])
                return cell
            }
            return UICollectionViewCell()
        }
    }

    func getEmployeeString() -> String {
        guard let company = self.company else {
            return ""
        }

        return self.getFormatedString(number: Double(company.employeeCount))
    }

    func getAnnualRevenueString() -> String {
        guard let company = self.company else {
            return ""
        }

        return String(format: "£%@", self.getFormatedString(number: company.turnover))
    }

    func getAnnualGrowthString() -> String {
        guard let company = self.company else {
            return ""
        }

        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.multiplier = 100
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 0
        if let percentString = percentFormatter.string(from: NSNumber(value: company.turnoverGrowth)) {
            if let percentNumber = percentFormatter.number(from: percentString) {
                if percentNumber == 0 {
                    return percentFormatter.string(from: NSNumber(value: 0))!
                }
            }
            return percentString
        }
        return ""
    }

    func getFormatedString(number: Double) -> String {
        let employeeBillion: Int = Int(number / billion)
        if employeeBillion != 0 {
            return String(format: "%.1f%@", number / billion, NSLocalizedString("b", comment: ""))
        }
        let employeeMillion: Int = Int(number / million)
        if employeeMillion != 0 {
            return String(format: "%.1f%@", number / million, NSLocalizedString("m", comment: ""))
        }
        let employeeThousand: Int = Int(number / thousand)
        if employeeThousand != 0 {
            return String(format: "%.1f%@", number / thousand, NSLocalizedString("k", comment: ""))
        }
        return String(format: "%.f", number)
    }
}
