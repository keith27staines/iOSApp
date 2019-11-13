
import Foundation
import WorkfinderCommon
import WorkfinderUI

class CompanySummarySectionRows {
    var viewData: CompanyViewData?
    
    var numberOfRows: Int { return SummarySectionRow.allCases.count }
    
    init(viewData: CompanyViewData) {
        self.viewData = viewData
    }
    
    enum SummarySectionRow: Int, CaseIterable {
        case industry = 0
        case postcode
        case summary
        case summaryText
        
        var reuseIdentifier: String {
            switch self {
            case .industry:
                return NameValueCell.reuseIdentifier
            case .postcode:
                return NameValueCell.reuseIdentifier
            case .summary:
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
        case .postcode:
            let nameValueCell = cell as! NameValueCell
            nameValueCell.nameLabel.text = "Postcode"
            nameValueCell.valueLabel.text = viewData?.postcode
            nameValueCell.nameValue.isButton = false
            nameValueCell.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        case .industry:
            let nameValueCell = cell as! NameValueCell
            nameValueCell.nameLabel.text = "Industry"
            nameValueCell.valueLabel.text = viewData?.industry
            nameValueCell.nameValue.isButton = false
            nameValueCell.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        case .summary:
            let nameValueCell = cell as! NameValueCell
            nameValueCell.nameValue.isButton = false
            nameValueCell.nameLabel.text = "Summary"
            nameValueCell.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        case .summaryText:
            let summaryCell = cell as! CompanySummaryTextCell
            summaryCell.expandableLabel.text = viewData?.description
            summaryCell.expandableLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
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
