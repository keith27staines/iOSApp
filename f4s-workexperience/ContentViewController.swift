//
//  TermsViewController.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 12/8/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import Reachability

class ContentViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var contentType: F4SContentType?
    var url: String?
    
    lazy var contentService: F4SContentServiceProtocol = {
        let service = F4SContentService()
        return service
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearance()
        getContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
}

// MARK: - adjust appearance
extension ContentViewController {
    func loadURL(url: String) {
        if let url = URL(string: url) {
            let urlRequest = URLRequest(url: url)
            self.webView.loadRequest(urlRequest)
        }
    }

    func adjustNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPage))
        doneButton.tintColor = UIColor(netHex: Colors.mediumGreen)
        doneButton.title = NSLocalizedString("Done", comment: "")
        self.navigationItem.leftBarButtonItem = doneButton
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    func adjustAppearance() {
        self.webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.webView.stringByEvaluatingJavaScript(from: "window.scroll(0,0)")
        self.webView.backgroundColor = UIColor.white
        self.webView.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.webView.delegate = self
        self.adjustNavigationBar()
    }
}

// MARK: - user interaction
extension ContentViewController {
    @objc func dismissPage() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - calls
extension ContentViewController {
    func getContent() {
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }

        if self.contentType == .company {
            MessageHandler.sharedInstance.showLightLoadingOverlay(self.webView)
            if let companyUrl = url {
                self.loadURL(url: companyUrl)
                return
            }
        }
        MessageHandler.sharedInstance.showLightLoadingOverlay(self.webView)
        contentService.getContent { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                guard let contentType = strongSelf.contentType else { return }
                switch result {
                case .error(let error):
                    MessageHandler.sharedInstance.hideLoadingOverlay()
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                case .success(let contentDescriptors):
                    guard let index = contentDescriptors.index(where: { (descriptor) -> Bool in descriptor.slug == contentType }) else { return }
                    guard let contentUrl = contentDescriptors[index].url else { return }
                    strongSelf.loadURL(url: contentUrl)
                }
            }
        }
    }
}

// MARK: - UIWebViewDelegate
extension ContentViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_: UIWebView) {
        self.webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.webView.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.webView.stringByEvaluatingJavaScript(from: "window.scroll(0,0)")
        MessageHandler.sharedInstance.hideLoadingOverlay()
    }

    func webView(_: UIWebView, didFailLoadWithError error: Error) {
        log.error(error)
        MessageHandler.sharedInstance.hideLoadingOverlay()
    }
}
