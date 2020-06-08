import UIKit
import WorkfinderUI

class ApplicationTile: UITableViewCell {
    static let reuseIdentifier = "applicationCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ApplicationTile.reuseIdentifier)
        configureViews()
    }
    
    let companyLogoWidth: CGFloat = 67
    
    lazy var logo: CompanyLogoView = {
        return CompanyLogoView(widthPoints: companyLogoWidth)
    }()
    
    lazy var statusViewContainer: UIView = {
        let view = UIView()
        view.addSubview(statusView)
        statusView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6))
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = WorkfinderColors.primaryColor
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: companyLogoWidth).isActive = true
        return view
    }()
    
    lazy var statusView: UILabel = {
       let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var logoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logo, UIView()])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    lazy var companyName: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.heading
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var industry: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.subHeading
        label.textColor = WorkfinderColors.textMedium
        return label
    }()
    
    lazy var hostInformation: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.heading
        label.textColor = WorkfinderColors.textMedium
        return label
    }()
    
    lazy var dateString: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.subHeading
        label.textColor = WorkfinderColors.textMedium
        return label
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            companyName,
            industry,
            hostInformation,
            dateString,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logoStack, textStack])
        stack.axis = .horizontal
        stack.spacing = 20
        return stack
    }()
    
    func configureViews() {
        self.contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 0))
        self.contentView.addSubview(statusViewContainer)
        statusViewContainer.anchor(top: mainStack.bottomAnchor, leading: logo.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 11, left: 0, bottom: 8, right: 0))
    }
    
    func configureWithApplication(_ application: ApplicationTilePresenter) {
        companyName.text = application.companyName
        industry.text = application.industry
        statusView.text = application.state.rawValue
        statusViewContainer.backgroundColor = application.state.capsuleColor
        hostInformation.text = application.hostInformation
        dateString.text = application.appliedDateString
        logo.load(companyName: application.companyName, urlString: application.logoUrl, completion: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
