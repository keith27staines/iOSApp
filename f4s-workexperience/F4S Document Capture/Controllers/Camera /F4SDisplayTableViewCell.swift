//
//  F4SDisplayTableViewCell.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SDisplayTableViewCellDelegate {
    func deletePage(_ page: F4SDocumentPageModel)
    func retakePage(_ page: F4SDocumentPageModel)
}

class F4SDisplayTableViewCell: UITableViewCell {
    var delegate: F4SDisplayTableViewCellDelegate?
    
    var page: F4SDocumentPageModel! {
        didSet {
            pageImageView.image = page?.image
        }
    }
    
    @IBAction func deletePage(_ sender: UIButton) {
        delegate?.deletePage(page)
    }
    
    @IBAction func retakePage(_ sender: UIButton) {
        delegate?.retakePage(page)
    }
    
    @IBOutlet weak var pageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
