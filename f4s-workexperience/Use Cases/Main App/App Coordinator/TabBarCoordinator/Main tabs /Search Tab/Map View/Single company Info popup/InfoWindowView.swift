//
//  InfoWindowView.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 25/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderUI

class InfoWindowView: UIView {

    @IBOutlet weak var primaryStackView: UIStackView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var industryNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var starsView: UIStackView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var firstStarImageView: UIImageView!
    @IBOutlet weak var secondStarImageView: UIImageView!
    @IBOutlet weak var thirdStarImageView: UIImageView!
    @IBOutlet weak var fourthStarImageView: UIImageView!
    @IBOutlet weak var fifthStarImageView: UIImageView!
    @IBOutlet weak var logoImageView: F4SSelfLoadingImageView!
    @IBOutlet weak var triangleView: TriangleView!

    @IBOutlet weak var backgroundView: UIView!
}
