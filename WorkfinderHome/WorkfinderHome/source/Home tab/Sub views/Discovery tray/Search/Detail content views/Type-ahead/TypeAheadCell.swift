
import UIKit
import WorkfinderUI

class TypeAheadCell: UITableViewCell {
    
    static let reuseIdentifier = "TypeAheadCell"
    
    lazy var icon: SafeSelfLoadingImageView = {
        let icon = SafeSelfLoadingImageView()
        icon.layer.cornerRadius = 12
        icon.layer.masksToBounds = true
        icon.layer.borderWidth = 1
        icon.layer.borderColor = UIColor.init(white: 0.9, alpha: 1).cgColor
        icon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var subtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(textStack)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    func updateFrom(_ typeAhead: TypeAheadItem) {
        let defaultImage = UIImage.from(size: CGSize(width: 40, height: 40), string: typeAhead.title ?? "", backgroundColor: WorkfinderColors.primaryColor)
        let downloadFromUrlString = typeAhead.iconUrlString ?? ""
        title.text = typeAhead.title
        subtitle.text = typeAhead.subtitle
        icon.load(urlString: downloadFromUrlString, defaultImage: defaultImage)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SafeSelfLoadingImageView: UIImageView {

    let imageLoader = ImageLoader()

    func load(urlString: String, defaultImage: UIImage) {
        imageLoader.load(urlString: urlString, defaultImage: defaultImage) { (downloadedFromUrl, image) in
            guard urlString == downloadedFromUrl else { return }
            self.image = image
        }
    }
}
