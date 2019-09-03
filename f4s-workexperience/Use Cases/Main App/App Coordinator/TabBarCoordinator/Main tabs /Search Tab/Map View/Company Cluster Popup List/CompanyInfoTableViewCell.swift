import UIKit
import WorkfinderCommon

class CompanyInfoTableViewCell: UITableViewCell {
    
    var company: Company! {
        didSet {
            self.companyNameLabel.attributedText = NSAttributedString(
                string: company.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
            
            self.industryLabel.attributedText = NSAttributedString(
                string: company.industry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            self.starRating.rating = Float(company.rating)
            self.starRating.isHidden = (company.rating == 0) ? true : false
            self.logo.image = UIImage(named: "DefaultLogo")
            self.logo.layer.cornerRadius = self.logo.frame.height/2.0
            self.logo.layer.masksToBounds = true
            self.logo.contentMode = .scaleAspectFit
            if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
                F4SImageService.sharedInstance.getImage(url: url, completion: { [weak self]
                    image in
                    if image != nil {
                        self?.logo.image = image!
                    } else {
                        self?.logo.image = UIImage(named: "DefaultLogo")
                    }
                })
            }
        }
    }

    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var starRating: StarRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
