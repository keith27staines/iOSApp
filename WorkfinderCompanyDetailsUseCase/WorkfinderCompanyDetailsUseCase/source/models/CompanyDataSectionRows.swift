

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

class CompanyDataSectionRows {
    
    enum DataSectionRow: Int, CaseIterable {
        case annualRevenue = 0
        case annualGrowth
        case numberOfEmployees
        case seeMore
        case employersLiabilityCertificate
        case safeguardingCertificate
        var identifier: String {
            switch self {
            case .annualRevenue: return "annualRevenue"
            case .annualGrowth: return "annualGrowth"
            case .numberOfEmployees: return "employees"
            case .seeMore: return "seeMore"
            case .employersLiabilityCertificate: return "ELC"
            case .safeguardingCertificate: return "SGC"
            }
        }
        
        var name: String {
            switch self {
            case .annualRevenue: return "Annual Revenue"
            case .annualGrowth: return "Annual Growth"
            case .numberOfEmployees: return "Employees"
            case .seeMore: return "See more"
            case .employersLiabilityCertificate: return "ELC"
            case .safeguardingCertificate: return "Safeguarding certificate"
            }
        }
        
        init?(identifier: String?) {
            switch identifier {
            case "annualRevenue": self = DataSectionRow.annualRevenue
            case "annualGrowth": self = DataSectionRow.annualGrowth
            case "employees": self = DataSectionRow.numberOfEmployees
            case "seeMore": self = DataSectionRow.seeMore
            case "ELC": self = DataSectionRow.employersLiabilityCertificate
            case "SGC": self = DataSectionRow.safeguardingCertificate
            default: return nil
            }
        }
    }
    
    unowned var viewModel: CompanyViewModel
    var viewData: CompanyViewData
    var numberOfRows: Int { return items.count }
    var items: [NameValueDescriptor] {
        var items = [
            makeDescriptor(rowType: .annualRevenue, value: self.viewData.revenueString, isButton: false),
            makeDescriptor(rowType: .annualGrowth, value: self.viewData.revenueString, isButton: false),
            makeDescriptor(rowType: .numberOfEmployees, value: self.viewData.employeesString, isButton: false)
            ]
        companyDocumentsModel.availableDocuments.forEach { (document) in
            let image = UIImage(named: "generic_document")?.scaledImage(with: CGSize(width: 18, height: 18))
            items.append(NameValueDescriptor(identifier: document.docType,
                                             name: document.name,
                                             value: "view document",
                                             isButton: true,
                                             buttonImage: image,
                                             link: document.url))
        }
        
        if !viewData.duedilIsHiden {
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
    
    unowned let companyDocumentsModel: F4SCompanyDocumentsModelProtocol
    
    init(viewModel: CompanyViewModel, companyDocumentsModel: F4SCompanyDocumentsModelProtocol) {
        self.viewModel = viewModel
        self.viewData = viewModel.companyViewData
        self.companyDocumentsModel = companyDocumentsModel
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
        if let url = url {
            viewModel.didTapLink(url: url)
        } else {
            viewModel.didTapDuedil(for: viewData)
        }
    }
}
