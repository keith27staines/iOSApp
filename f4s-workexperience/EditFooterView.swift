//
//  FooterView.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/25/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class EditFooterView: UIView {

    @IBOutlet weak var footerLabel: UILabel!

    static var footerString: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        if let view = Bundle.main.loadNibNamed("EditFooter", owner: self, options: nil)?[0] as? UIView {
            view.isUserInteractionEnabled = false
            view.backgroundColor = UIColor(netHex: Colors.lightGray)
            view.frame = frame

            let string1 = NSAttributedString(string: EditFooterView.footerString, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.gray)])
            footerLabel.numberOfLines = 3
            footerLabel.attributedText = string1
            self.addSubview(view)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
