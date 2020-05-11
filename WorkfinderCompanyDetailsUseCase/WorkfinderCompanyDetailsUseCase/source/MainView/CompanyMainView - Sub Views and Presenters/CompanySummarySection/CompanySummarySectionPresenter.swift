 
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
    var numberOfRows: Int { return SummarySectionRow.allCases.count }
    
    init(companyWorkplace: CompanyWorkplace) {
        self.companyWorkplace = companyWorkplace
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
        guard
            let sectionRow = SummarySectionRow(rawValue: row),
            let cell = tableView.dequeueReusableCell(withIdentifier: sectionRow.reuseIdentifier)
            else { return UITableViewCell() }
        
        switch sectionRow {
        case .summaryText:
            guard let summaryCell = cell as? CompanySummaryTextCell else { break }
            let description = company.description ?? ""
            summaryCell.expandableLabel.text = description
            summaryCell.expandableLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
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

class CompanySummaryTextCell: UITableViewCell {
    static var reuseIdentifier = "CompanySummaryTextCell"
    
    let expandableLabel = ExpandableLabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(expandableLabel)
        expandableLabel.fillSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
