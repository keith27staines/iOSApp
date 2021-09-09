import UIKit
import WorkfinderUI

class ApplicationTile: UITableViewCell {
    
    let spacing = WFMetrics.standardSpace
    
    static let reuseIdentifier = "applicationCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ApplicationTile.reuseIdentifier)
        configureViews()
    }
    
    let companyLogoWidth: CGFloat = 72
    
    lazy var logo: CompanyLogoView = {
        return CompanyLogoView(widthPoints: companyLogoWidth)
    }()

    lazy var logoStack: UIStackView = {
        let topSpace = UIView()
        let bottomSpace = UIView()
        let stack = UIStackView(arrangedSubviews: [
            topSpace,
            logo,
            bottomSpace
        ])
        stack.axis = .vertical
        topSpace.heightAnchor.constraint(equalTo: bottomSpace.heightAnchor).isActive = true
        return stack
    }()

    
    lazy var statusTag: WFTextCapsule = {
        WFComponentsFactory.makeSmallTag()
    }()
    
    lazy var companyName: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.bodyTextBold
        style.color = WFColorPalette.offBlack
        label.applyStyle(style)
        label.numberOfLines = 0
        label.constrainToMaxlinesOrFewer(maxLines: 2)
        return label
    }()
    
    lazy var roleName: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.smallLabelTextRegular
        style.color = WFColorPalette.offBlack
        label.applyStyle(style)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var applicationDate: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.smallLabelTextRegular
        style.color = WFColorPalette.grayLight
        label.applyStyle(style)
        return label
    }()
        
    lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            companyName,
            roleName,
            applicationDate
        ])
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
        
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            logo,
            textStack,
            UIView()
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = spacing
        return stack
    }()
    
    lazy var tile: UIView = {
        let view = UIView()
        view.layer.cornerRadius = spacing
        view.layer.borderColor = WFColorPalette.grayBorder.cgColor
        view.layer.borderWidth = WFMetrics.borderWidth
        view.addSubview(mainStack)
        mainStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing))
        return view
    }()
    
    func configureViews() {
        contentView.addSubview(tile)
        tile.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0))
    }
    
    func configureWithApplication(_ application: ApplicationTilePresenter) {
        companyName.text = application.companyName
        statusTag.text = application.state.rawValue
        let color = application.state.capsuleColor
        statusTag.setColors(backgroundColor: WFColorPalette.white, borderColor: color, textColor: color)
        roleName.text = application.roleName
        applicationDate.text = application.appliedDateString
        logo.load(companyName: application.companyName, urlString: application.logoUrl, completion: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
