
import UIKit
import WorkfinderUI

class LandscapeRoleCell: UITableViewCell, Presentable {
    
    static var identifer = "LandscapeRoleCell"
    var row: Int = 0
    var presenter: RecentRolesDataSource!
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? RecentRolesDataSource else { return }
        self.presenter = presenter
        companyLogo.image = presenter.imageForRow(row)
        let roleData: RoleData = presenter.roleForRow(row)
        presentWith(roleData)
    }
    
    func presentWith(_ roleData: RoleData) {
        companyName.text = roleData.companyName ?? "Not specified"
        projectTitle.text = roleData.projectTitle
        payIconLabel.label.text = roleData.paidAmount
        hoursIconLabel.label.text = roleData.workingHours ?? "Not specified"
        locationIconLabel.label.text = roleData.location
    }
    
    lazy var companyLogo: UIImageView = UIImageView.companyLogoImageView(width: 68)
    
    lazy var companyLogoStack: UIStackView = {
        let padding = UIView()
        let stack = UIStackView(arrangedSubviews: [
            companyLogo,
            padding
        ])
        stack.axis = .vertical
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
        backgroundColor = UIColor.blue
        contentView.addSubview(mainStack)
        contentView.addSubview(separator)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 21, left: 23, bottom: 15, right: 17))
        separator.anchor(top: nil, leading: nil, bottom: contentView.bottomAnchor, trailing: nil)
        separator.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class IconLabel: UIView {
    
    lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return icon
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                icon,
                label
            ]
        )
        stack.axis = .horizontal
        stack.spacing = 11
        return stack
    }()
    
    init(iconImage: UIImage?) {
        super.init(frame: CGRect.zero)
        self.icon.image = iconImage
        configureViews()
    }
    
    func configureViews() {
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

