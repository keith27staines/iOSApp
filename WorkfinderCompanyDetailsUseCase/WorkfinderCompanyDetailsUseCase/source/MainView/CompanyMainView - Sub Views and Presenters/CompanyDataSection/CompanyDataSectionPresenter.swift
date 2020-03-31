

import UIKit
import WorkfinderCommon

struct NameValueDescriptor {
    var identifier: String? = nil
    var name: String = "name"
    var value: String = ""
    var isButton: Bool = false
    var buttonImage: UIImage? = nil
    var link: URL? = nil
}

protocol CompanyDataSectionPresenterProtocol: class {
    var numberOfRows: Int { get }
    var revenueString: String { get }
    var growthString: String { get }
    var numberOfEmployees: String { get }
    var duedilIsHidden: Bool { get }
    func cellForRow(_ row: Int, in tableView: UITableView) -> UITableViewCell
}

class CompanyDataSectionPresenter: CompanyDataSectionPresenterProtocol {
    
    var numberOfRows: Int { return items.count }
    var company: CompanyJson { return self.companyWorkplace.companyJson }
    
    var revenueString: String {
        let turnover = ScaledNumber(amount: company.turnover ?? 0).formattedString()
        return String(turnover)
    }
    
    var growthString: String {
        let growth = ScaledNumber(amount: company.growth ?? 0).formattedString()
        return String(growth)
    }
    
    var numberOfEmployees: String { String(company.employeeCount ?? 0) }
    
    var duedilIsHidden: Bool { return false }
    
    enum DataSectionRow: Int, CaseIterable {
        case annualRevenue = 0
        case annualGrowth
        case numberOfEmployees
        case seeMore
        var identifier: String {
            switch self {
            case .annualRevenue: return "annualRevenue"
            case .annualGrowth: return "annualGrowth"
            case .numberOfEmployees: return "employees"
            case .seeMore: return "seeMore"
            }
        }
        
        var name: String {
            switch self {
            case .annualRevenue: return "Annual Revenue"
            case .annualGrowth: return "Annual Growth"
            case .numberOfEmployees: return "Employees"
            case .seeMore: return "See more"
            }
        }
        
        init?(identifier: String?) {
            switch identifier {
            case "annualRevenue": self = DataSectionRow.annualRevenue
            case "annualGrowth": self = DataSectionRow.annualGrowth
            case "employees": self = DataSectionRow.numberOfEmployees
            case "seeMore": self = DataSectionRow.seeMore
            default: return nil
            }
        }
    }
    
    var items: [NameValueDescriptor] {
        var items = [
            makeDescriptor(rowType: .annualRevenue, value: self.revenueString, isButton: false),
            makeDescriptor(rowType: .annualGrowth, value: self.growthString, isButton: false),
            makeDescriptor(rowType: .numberOfEmployees, value: self.numberOfEmployees, isButton: false)
            ]
        
        if !duedilIsHidden {
            let image = UIImage(named: "Duedil")?.scaledImage(with: CGSize(width: 18, height: 18))
            items.append(NameValueDescriptor(identifier: DataSectionRow.seeMore.identifier,
                                             name: DataSectionRow.seeMore.name,
                                             value: "see more information...",
                                             isButton: true,
                                             buttonImage: image,
                                             link: nil))
        }
        return items
    }
    
    func nameValueForRow(_ row: Int) -> NameValueDescriptor {
        return items[row]
    }
    
    func makeDescriptor(rowType: DataSectionRow,
                        value: String,
                        isButton: Bool,
                        buttonImage: UIImage? = nil,
                        link: URL? = nil) -> NameValueDescriptor {
        return NameValueDescriptor(identifier: rowType.identifier,
                                   name: rowType.name,
                                   value: value,
                                   isButton: isButton,
                                   buttonImage: nil,
                                   link: nil)
    }
    let companyWorkplace: CompanyWorkplace
    init(companyWorkplace: CompanyWorkplace) {
        self.companyWorkplace = companyWorkplace
    }
    
    func cellForRow(_ row: Int, in tableView: UITableView) -> UITableViewCell {
        let nameValueCell = tableView.dequeueReusableCell(withIdentifier: NameValueCell.reuseIdentifier) as! NameValueCell
        let nameValue = nameValueForRow(row)
        let rowType = DataSectionRow(identifier: nameValue.identifier)
        switch rowType {
        case .seeMore:
            nameValueCell.configureWithNameValue(nameValue, tapAction: duedilTap)
        default:
            nameValueCell.configureWithNameValue(nameValue)
        }
        return nameValueCell
    }
    
    func duedilTap(url: URL? = nil) {
    
    }
}
