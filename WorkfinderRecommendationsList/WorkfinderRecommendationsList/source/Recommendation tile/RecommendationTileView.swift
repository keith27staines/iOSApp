
import UIKit
import WorkfinderUI

class RecommendationTileView: UITableViewCell {
    
    var presenter: RecommendationTilePresenter? {
        didSet {
            presenter?.view = self
            presenter?.loadData()
        }
    }
    
    override func prepareForReuse() {
        presenter?.view = nil
        presenter = nil
    }
    
    lazy var companyNameLabel = UILabel()
    lazy var industryLabel = UILabel()
    lazy var hostNameLabel = UILabel()
    lazy var hostRoleLabel = UILabel()
    lazy var companyLogo = CompanyLogoView()
    lazy var hostPhoto = HostPhotoView()
    
    lazy var companyStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.companyNameLabel,
            self.industryLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 8
        let stack = UIStackView(arrangedSubviews: [
            self.companyLogo,
            textStack
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var hostStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.hostNameLabel,
            self.hostRoleLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 8
        let stack = UIStackView(arrangedSubviews: [
            self.hostPhoto,
            textStack
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var fullStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.companyStack,
            self.hostStack
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    lazy var tileView: UIView = {
        let view = UIView()
        view.addSubview(fullStack)
        fullStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.layer.shadowColor = UIColor.init(white: 0.0, alpha: 1).cgColor
        view.layer.shadowRadius = 10
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    func configureViews() {
        contentView.addSubview(tileView)
        tileView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 4))
        hostNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        hostRoleLabel.font = WorkfinderFonts.subHeading
        hostRoleLabel.textColor = WorkfinderColors.textMedium
        companyNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        industryLabel.font = WorkfinderFonts.subHeading
        industryLabel.textColor = WorkfinderColors.textMedium
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

