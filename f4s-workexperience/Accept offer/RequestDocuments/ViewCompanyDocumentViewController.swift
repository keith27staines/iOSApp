//
//  ViewDocumentViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class ViewCompanyDocumentViewController: UIViewController {
    
    var document: F4SCompanyDocument? {
        didSet {
            guard let url = document?.url else {
                return
            }
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    lazy var webView: UIWebView = {
        let webView = UIWebView()
        view.addSubViewToFillSafeArea(view: webView)
        return webView
    }()

}
