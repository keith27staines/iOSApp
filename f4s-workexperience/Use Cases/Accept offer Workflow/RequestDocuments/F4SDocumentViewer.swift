//
//  ViewDocumentViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 04/08/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WebKit
import WorkfinderCommon

class F4SDocumentViewer: UIViewController, WKUIDelegate {
    
    func showCompanyDocument(_ document: F4SCompanyDocument?) {
        showUrl(url: document?.url)
    }
    
    func showUrlString(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        showUrl(url: url)
    }
    
    func showUrl(url: URL?) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view.addSubViewToFillSafeArea(view: webView)
        return webView
    }()
}
