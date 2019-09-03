import UIKit
import WorkfinderCommon
import WorkfinderUI

class CompanyInfoTableViewCell: UITableViewCell {
    
    var company: Company! {
        didSet {
            self.companyNameLabel.attributedText = NSAttributedString(
                string: company.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
            
            self.industryLabel.attributedText = NSAttributedString(
                string: company.industry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            self.starRating.rating = Float(company.rating)
            self.starRating.isHidden = (company.rating == 0) ? true : false
            self.logo.layer.cornerRadius = self.logo.frame.height/2.0
            self.logo.layer.masksToBounds = true
            self.logo.contentMode = .scaleAspectFit
            self.logo.load(urlString: company.logoUrl, defaultImage: UIImage(named: "DefaultLogo"))
        }
    }

    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var logo: F4SSelfLoadingImageView!
    @IBOutlet weak var starRating: StarRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
