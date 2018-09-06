//
//  CompanyDocumentTableViewCell.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class CompanyDocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var documentName: UILabel!
    
    var document: F4SCompanyDocument? {
        didSet {
            spinner.stopAnimating()
            accessoryType = document?.isViewable == true ? .disclosureIndicator : .none
            selectionStyle = document?.isViewable == true ? .blue : .none
            icon.image = iconForDocument(document: document)
            documentName.text = textForDocument(document: document)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func iconForDocument(document: F4SCompanyDocument?) -> UIImage? {
        guard let document = document else { return nil }
        switch document.state {
        case .available:
            if document.url == nil {
                return #imageLiteral(resourceName: "checkBlue")
            } else {
                return #imageLiteral(resourceName: "company_doc")
            }
            
        case .requested, .unrequested, .unavailable:
            return nil
        }
    }
    func textForDocument(document: F4SCompanyDocument?) -> String {
        guard let document = document else { return "" }
        switch document.state {
        case .available:
            return document.providedNameOrDefaultName
        case .unavailable, .requested, .unrequested:
            return ""
        }
    }

}
