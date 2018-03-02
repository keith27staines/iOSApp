//
//  CVGuideViewerViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 22/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WebKit

class CVGuideViewerViewController: UIViewController, WKUIDelegate {

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if #available(iOS 11.0, *) {
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            // Fallback on earlier versions
            webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string:"https://interactive.barclayslifeskills.com/staticmodules/downloads/cv-tips.pdf")!
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}
