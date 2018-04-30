//
//  F4SRequestCompanyDocumentViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 30/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SRequestCompanyDocumentViewController: UIViewController {

    var documentModel: F4SCompanyDocumentsModel!
    
    @IBOutlet var documentLabelCollection: [UILabel]!
    
    @IBOutlet var documentLabelContainer: [UIView]!
    override func viewDidLoad() {
        super.viewDidLoad()
        documentLabelContainer[0].isHidden = true
        documentLabelContainer[1].isHidden = true
        for (i,document) in documentModel.unrequestedDocuments.enumerated() {
            documentLabelCollection[i].text = "Request \(document.name)"
            documentLabelContainer[i].isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func document1Tapped(_ sender: Any) {
    }
    
    
    @IBOutlet var document2Tapped: UITapGestureRecognizer!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
