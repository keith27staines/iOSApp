//
//  MessageOptionCollectionViewCell.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 1/4/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//
import UIKit
import WorkfinderUI

class MessageOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var answerLabel: OptionLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        guard let nibView = __bundle.loadNibNamed("MessageOptionCollectionViewCell", owner: self, options: nil)?[0] as? UICollectionViewCell else {
            return
        }
        nibView.frame = self.bounds
        nibView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        nibView.isUserInteractionEnabled = false
        self.addSubview(nibView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
