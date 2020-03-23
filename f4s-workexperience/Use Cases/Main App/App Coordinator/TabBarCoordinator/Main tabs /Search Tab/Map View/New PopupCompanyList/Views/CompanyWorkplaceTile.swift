
import UIKit
import WorkfinderUI

class CompanyWorkplaceTile: UITableViewCell {
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var industryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        return label
    }()
    
    lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, industryLabel])
        stack.axis = .vertical
        return stack
    }()
    
    lazy var logoView: F4SSelfLoadingImageView = {
        let logoView = F4SSelfLoadingImageView()
        logoView.layer.cornerRadius = 8
        logoView.layer.borderWidth = 2
        logoView.layer.masksToBounds = true
        logoView.layer.borderColor = UIColor.lightGray.cgColor
        logoView.contentMode = .scaleAspectFit
        logoView.layer.shadowRadius = 5
        logoView.layer.shadowColor = UIColor.black.cgColor
        return logoView
    }()
    
    func buildView() {
        contentView.addSubview(labelStack)
        contentView.addSubview(logoView)
        logoView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 0))
        labelStack.anchor(top: contentView.topAnchor, leading: logoView.trailingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 4))
        logoView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    func configureWithViewData(_ viewData: CompanyTileViewData) {
        nameLabel.text = viewData.companyName
        industryLabel.text = "which industry?"
        logoView.load(
            urlString: viewData.logoUrlString,
            defaultImage: UIImage(named: "DefaultLogo"))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
