//
//  RatingTableViewCell.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/16/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var firstStarImageView: UIImageView!
    @IBOutlet weak var secondStarImageView: UIImageView!
    @IBOutlet weak var thirdStarImageView: UIImageView!
    @IBOutlet weak var fourthStarImageView: UIImageView!
    @IBOutlet weak var fifthStarImageView: UIImageView!
    @IBOutlet weak var starsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func halfStar() -> UIImage? {
        return UIImage(named: "HalfStar")?.withRenderingMode(.alwaysTemplate)
    }
    func fullStar() -> UIImage? {
        return UIImage(named: "FilledStar")?.withRenderingMode(.alwaysTemplate)
    }

    func setupStars(rating: Double) {
        let roundedRating = rating.round()

        if roundedRating == 0.5 {
            self.firstStarImageView.image = #imageLiteral(resourceName: "HalfStar")
        }
        if roundedRating == 1 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 1.5 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 2 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 2.5 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
            self.thirdStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 3 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
            self.thirdStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 3.5 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
            self.thirdStarImageView.image = UIImage(named: "FilledStar")
            self.fourthStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 4 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
            self.thirdStarImageView.image = UIImage(named: "FilledStar")
            self.fourthStarImageView.image = UIImage(named: "FilledStar")
        }
        if roundedRating == 4.5 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
            self.thirdStarImageView.image = UIImage(named: "FilledStar")
            self.fourthStarImageView.image = UIImage(named: "FilledStar")
            self.fifthStarImageView.image = UIImage(named: "HalfStar")
        }
        if roundedRating == 5 {
            self.firstStarImageView.image = UIImage(named: "FilledStar")
            self.secondStarImageView.image = UIImage(named: "FilledStar")
            self.thirdStarImageView.image = UIImage(named: "FilledStar")
            self.fourthStarImageView.image = UIImage(named: "FilledStar")
            self.fifthStarImageView.image = UIImage(named: "FilledStar")
        }
        
        [firstStarImageView, secondStarImageView,thirdStarImageView,fourthStarImageView,fifthStarImageView].forEach { (view) in
            view?.tintColor = UIColor.red
        }
    }
}
