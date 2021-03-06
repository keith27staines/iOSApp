
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyHeaderViewProtocol: AnyObject {
    var presenter: CompanyHeaderViewPresenterProtocol! { get set }
    func refresh(from presenter: CompanyHeaderViewPresenterProtocol)
}

class CompanyHeaderView: UIView, CompanyHeaderViewProtocol {
    
    var presenter: CompanyHeaderViewPresenterProtocol!
    
    init(presenter: CompanyHeaderViewPresenterProtocol) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        presenter.attach(view: self)
        configureViews()
        refresh(from: presenter)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func refresh(from presenter: CompanyHeaderViewPresenterProtocol) {
        companyNameLabel.text = presenter.companyName
        companyIconImageView.load(
            companyName: presenter.companyName,
            urlString: presenter.logoUrlString, completion: nil)
        distanceLabel.text = presenter.distanceFromCompany
    }
    
    let iconViewRadius = CGFloat(10)
    let iconViewSize = CGSize(width: 96, height: 96)
    
    lazy var iconContainerView: UIView = {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: self.iconViewSize))
        view.clipsToBounds = false
        view.addSubview(self.companyIconImageView)
        self.companyIconImageView.fillSuperview()
        return view
    }()
    
    lazy var companyIconImageView: CompanyLogoView = {
        let imageView = CompanyLogoView(widthPoints: 96)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
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
        label.textColor = distanceLabelColor
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
