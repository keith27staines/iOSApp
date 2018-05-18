//
//  F4SDocumentViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 19/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WebKit

class F4SDocumentViewController: UIViewController {
    var webView: WKWebView!
    
    var documentUrl: URL!
    @IBOutlet weak var webContainerView: UIView!
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webContainerView.addSubview(webView)
        webView.leftAnchor.constraint(equalTo: webContainerView.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webContainerView.rightAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: webContainerView.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let request = URLRequest(url: documentUrl)
        webView.load(request)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
