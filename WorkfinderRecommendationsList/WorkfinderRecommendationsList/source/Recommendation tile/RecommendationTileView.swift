
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
    
    lazy var companyLogo = CompanyLogoView(widthPoints: 70, defaultLogoName: nil)
    lazy var hostPhoto = HostPhotoView(widthPoints: 55, defaultLogoName: nil)
    
    lazy var companyLogoStack: UIStackView = {
        let padding = UIView()
        let stack = UIStackView(arrangedSubviews: [
            companyLogo,
            padding
        ])
        stack.axis = .vertical
        return stack
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.constrainToMaxlinesOrFewer(maxLines: 2)
        return label
    }()
    
    lazy var hostNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 33/255, alpha: 1)
        label.numberOfLines = 1
        return label
    }()
    lazy var hostRoleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 184/255, alpha: 1)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var companyTextStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.companyNameLabel,
            UIView()
        ])
        textStack.axis = .vertical
        textStack.spacing = 4
        return textStack
    }()
    
    lazy var hostTextStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [
            self.hostNameLabel,
            self.hostRoleLabel,
        ])
        textStack.axis = .vertical
        textStack.spacing = 0
        return textStack
    }()
    
    lazy var allTextStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.companyTextStack,
            self.hostTextStack,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    lazy var fullStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            companyLogoStack,
            allTextStack,
            UIView()
        ])
        stack.spacing = 20
        stack.alignment = .leading
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var tileView: UIView = {
        let view = UIView()
        view.addSubview(fullStack)
        fullStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        configureViews()
    }
    
    func configureViews() {
        contentView.addSubview(tileView)
        contentView.backgroundColor = UIColor.white
        tileView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        let underline = UIView()
        underline.backgroundColor = UIColor.init(white: 200/255, alpha: 1)
        underline.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        contentView.addSubview(underline)
        underline.anchor(top: nil, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }
    
    @objc func handleTap() { presenter?.onTileTapped() }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}



