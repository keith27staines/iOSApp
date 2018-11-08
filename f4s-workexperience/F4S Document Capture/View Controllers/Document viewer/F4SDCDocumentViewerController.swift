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
    var document: F4SDocument!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDocument()
    }
    
    func loadDocument() {
        if let url = document.viewableUrl {
            print("loading document")
            MessageHandler.sharedInstance.showLoadingOverlay(self.view)
            let request = URLRequest(url: url)
            webview.delegate = self
            webview.loadRequest(request)
        }
    }
}

extension F4SDCDocumentViewerController : UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finished loading document")
        MessageHandler.sharedInstance.hideLoadingOverlay()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("failed to load document")
        MessageHandler.sharedInstance.hideLoadingOverlay()
        let alert = UIAlertController(title: "Unable to load document", message: error.localizedDescription, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.loadDocument()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
