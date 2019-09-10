//
//  F4SDisplayTableViewCell.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SDisplayTableViewCellDelegate {
    func deletePage(_ page: F4SDocumentPage)
    //func retakePage(_ page: F4SDocumentPage)
}

class F4SDisplayTableViewCell: UITableViewCell {
    var delegate: F4SDisplayTableViewCellDelegate?
    
    var page: F4SDocumentPage! {
        didSet {
            pageImageView.image = page?.image
        }
    }
    
    @IBAction func deletePage(_ sender: UIButton) {
        delegate?.deletePage(page)
    }
    
//    @IBAction func retakePage(_ sender: UIButton) {
//        delegate?.retakePage(page)
//    }
    
    @IBOutlet weak var pageImageView: UIImageView!

}
