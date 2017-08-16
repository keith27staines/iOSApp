//
//  MessageOptionCollectionViewCell.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 1/4/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//
import UIKit

class MessageOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var answerLabel: OptionLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        guard let nibView = Bundle.main.loadNibNamed("MessageOptionCollectionViewCell", owner: self, options: nil)?[0] as? UICollectionViewCell else {
            return
        }
        nibView.frame = self.bounds
        nibView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        nibView.isUserInteractionEnabled = false
        self.addSubview(nibView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
