//
//  ViewDocumentViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class ViewDocumentViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    var document: F4SCompanyDocument!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = document.url else {
            return
        }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }

}
