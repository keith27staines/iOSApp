//
//  DocumentViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDCDocumentViewerController: UIViewController {
    
    @IBOutlet weak var webview: UIWebView!
    var document: F4SDCDocumentUpload!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = document.viewableUrl {
            let request = URLRequest(url: url)
            webview.loadRequest(request)
        }
    }

}
