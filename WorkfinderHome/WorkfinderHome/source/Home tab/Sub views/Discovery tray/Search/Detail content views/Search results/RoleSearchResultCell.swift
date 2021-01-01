
import UIKit
import WorkfinderUI

class RoleSearchResultCell: UITableViewCell {
    
    static var identifer = "RoleSearchResultCell"
    var row: Int = 0
    var presenter: RecentRolesDataSource!
    var logoUrlString: String?
    var roleData: RoleData?
    
    func presentWith(_ roleData: RoleData) {
        self.roleData = roleData
        companyName.text = roleData.companyName ?? "Not specified"
        projectTitle.text = roleData.projectTitle
        payIconLabel.label.text = roleData.paidAmount
        hoursIconLabel.label.text = roleData.workingHours ?? "Not specified"
        locationIconLabel.label.text = roleData.location
        logoUrlString = roleData.companyLogoUrlString
        companyLogo.load(
            companyName: roleData.companyName ?? " ",
            urlString: roleData.companyLogoUrlString) {
        }
    }
    
    lazy var companyLogo: CompanyLogoView = {
        CompanyLogoView(widthPoints: 68, defaultLogoName: nil)
    }()
    
    lazy var companyLogoStack: UIStackView = {
        let padding = UIView()
        let stack = UIStackView(arrangedSubviews: [
            companyLogo,
            padding
        ])
        stack.axis = .vertical
        stack.widthAnchor.constraint(equalToConstant: 70).isActive = true
        return stack
    }()
    
    lazy var projectTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.black
        label.text = "Project Title"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var companyName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.init(white: 112/255, alpha: 1)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            UIView.verticalSpaceView(height: 4),
            projectTitle,
            companyName
        ])
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    lazy var payIconLabel: IconLabel = { IconLabel(iconImage: UIImage(named:"dt_hourly_rate")) }()
    lazy var hoursIconLabel: IconLabel = { IconLabel(iconImage: UIImage(named:"dt_placement_type")) }()
    lazy var locationIconLabel:IconLabel = { IconLabel(iconImage: UIImage(named:"dt_location")) }()
    
    lazy var payAndHoursStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(payIconLabel)
        stack.addArrangedSubview(hoursIconLabel)
        stack.spacing = 30
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(payAndHoursStack)
        stack.addArrangedSubview(locationIconLabel)
        stack.addArrangedSubview(UIView())
        stack.spacing = 13
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(titleStack)
        stack.addArrangedSubview(detailsStack)
        stack.spacing = 10
        stack.axis = .vertical
        stack.alignment = .fill
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(companyLogoStack)
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(UIView())
        stack.spacing = 20
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 216/255, alpha: 0.5)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    func configureViews() {
        contentView.addSubview(mainStack)
        contentView.addSubview(separator)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 21, left: 0, bottom: 15, right: 0))
        separator.anchor(top: nil, leading: nil, bottom: contentView.bottomAnchor, trailing: nil)
        separator.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
