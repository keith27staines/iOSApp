
import Foundation
import WorkfinderCommon
import WorkfinderUI

protocol CompanySummarySectionPresenterProtocol {
    var numberOfRows: Int { get }
    func cellForRow(_ row: Int, in tableView: UITableView) -> UITableViewCell
}

 class CompanySummarySectionPresenter: CompanySummarySectionPresenterProtocol {
    let companyWorkplace: CompanyWorkplace
    var company: CompanyJson { companyWorkplace.companyJson }
    var numberOfRows: Int { return summarySectionRowModel.count }
    
    init(companyWorkplace: CompanyWorkplace) {
        self.companyWorkplace = companyWorkplace
        buildSummarySectionRowModel()
    }
    
    var summarySectionRowModel = [SummarySectionRow]()
    
    func buildSummarySectionRowModel() {
        summarySectionRowModel = [SummarySectionRow]()
        if (company.description?.count ?? 0) > 0 {
            summarySectionRowModel.append(SummarySectionRow.summaryText)
        }
        if company.industries?.count ?? 0 > 0 {
            summarySectionRowModel.append(SummarySectionRow.industry)
        }
        summarySectionRowModel.append(SummarySectionRow.postcode)
    }
    
    enum SummarySectionRow: Int, CaseIterable {
        case summaryText
        case industry
        case postcode
        
        var reuseIdentifier: String {
            switch self {
            case .industry:
                return NameValueCell.reuseIdentifier
            case .postcode:
                return NameValueCell.reuseIdentifier
            case .summaryText:
                return CompanySummaryTextCell.reuseIdentifier
            }
        }
    }
    
    func cellForRow(_ row: Int, in tableView: UITableView) -> UITableViewCell {
        let sectionRow = summarySectionRowModel[row]
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionRow.reuseIdentifier)
            else { return UITableViewCell() }
        
        switch sectionRow {
        case .summaryText:
            guard let summaryCell = cell as? CompanySummaryTextCell else { break }
            summaryCell.label.font = UIFont.systemFont(ofSize: 15, weight: .light)
            let description = company.description ?? ""
            summaryCell.label.text = description
            
        case .postcode:
            guard let nameValueCell = cell as? NameValueCell else { break }
            nameValueCell.nameLabel.text = "Postcode"
            nameValueCell.valueLabel.text = companyWorkplace.postcode
            nameValueCell.nameValue.isButton = false
            nameValueCell.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        case .industry:
            guard let nameValueCell = cell as? NameValueCell else { break }
            nameValueCell.nameLabel.text = "Industry"
            nameValueCell.valueLabel.text = company.industries?.first?.name
            nameValueCell.nameValue.isButton = false
            nameValueCell.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        }
        return cell
    }
    
}
