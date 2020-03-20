
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyHeaderViewProtocol: class {
    var presenter: CompanyHeaderViewPresenterProtocol! { get set }
    func refresh(from presenter: CompanyHeaderViewPresenterProtocol)
}

class CompanyHeaderView: UIView, CompanyHeaderViewProtocol {
    
    var presenter: CompanyHeaderViewPresenterProtocol!
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        configureViews()
        refresh(from: presenter)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func refresh(from presenter: CompanyHeaderViewPresenterProtocol) {
        companyNameLabel.text = presenter.companyName
        companyIconImageView.load(urlString: presenter.logoUrlString, defaultImage: UIImage(named: "DefaultLogo"))
        distanceLabel.text = presenter.distanceFromCompany
    }
    
    let iconViewRadius = CGFloat(10)
    let iconViewSize = CGSize(width: 96, height: 96)
    
    lazy var iconContainerView: UIView = {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: self.iconViewSize))
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: iconViewRadius).cgPath
        view.addSubview(self.companyIconImageView)
        self.companyIconImageView.fillSuperview()
        return view
    }()
    
    lazy var companyIconImageView: F4SSelfLoadingImageView = {
        let imageView = F4SSelfLoadingImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = iconViewRadius
        return imageView
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let distanceLabelColor = UIColor.init(white: 0.5, alpha: 1)
    
    lazy var distanceStack: UIStackView = {
        
        let locationImage = UIImage(named: "location")?.withRenderingMode(.alwaysTemplate)
        let locationIcon = UIImageView(image: locationImage)
        locationIcon.contentMode = .scaleAspectFit
        locationIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true
        locationIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        locationIcon.tintColor = self.distanceLabelColor
        let stack = UIStackView(arrangedSubviews: [locationIcon, self.distanceLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.text = "2.0 km away"
        label.textColor = UIColor.init(white: 0.5, alpha: 1)
        return label
    }()
    
    func configureViews() {
        addSubview(iconContainerView)
        addSubview(companyNameLabel)
        addSubview(distanceStack)
        iconContainerView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8), size: iconViewSize)
        companyNameLabel.anchor(top: nil, leading: companyIconImageView.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), size: CGSize.zero)
        companyNameLabel.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor).isActive = true
        distanceStack.anchor(top: companyNameLabel.bottomAnchor, leading: companyNameLabel.leadingAnchor, bottom: nil, trailing: companyNameLabel.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
    }
}
