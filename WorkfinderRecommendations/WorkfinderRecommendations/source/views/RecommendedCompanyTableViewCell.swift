/// 

import UIKit
import WorkfinderCommon
import WorkfinderUI

class CompanyCell : UITableViewCell {
    
    var company: Company? {
        didSet {
            guard let company = company else {
                self.companyNameLabel.attributedText = nil
                self.industryLabel.attributedText = nil
                self.starRating.rating = 0
                self.logo.image = nil
                return
            }
            self.companyNameLabel.attributedText = NSAttributedString(
                string: company.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
            
            self.industryLabel.attributedText = NSAttributedString(
                string: company.industry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            self.starRating.rating = Float(company.rating)
            self.starRating.isHidden = (company.rating == 0) ? true : false
            self.logo.load(urlString: company.logoUrl, defaultImage: UIImage(named: "DefaultLogo"))
        }
    }
    
    lazy var industryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var logo: F4SSelfLoadingImageView = {
        let imageView = F4SSelfLoadingImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var starRating: StarRatingView = {
        let ratingView = StarRatingView(frame: CGRect.zero)
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        return ratingView
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [companyNameLabel,starRating,industryLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = UIStackView.Alignment.leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        addSubview(logo)
        addSubview(stackView)
        logo.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
        logo.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        stackView.leftAnchor.constraint(equalTo: logo.rightAnchor, constant: 12).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
