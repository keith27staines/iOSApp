//
//  WebViewController.swift
//  WebView
//
//  Created by Keith Dev on 08/05/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import WebKit

public protocol F4SWebViewControllerDelegate : class {
    func webViewControllerDidFinish(_ vc: F4SWebViewController)
}

public class F4SWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    let urlString: String
    let isNavigationAllowed: Bool
    weak var delegate: F4SWebViewControllerDelegate?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barTintColor = UIColor.white
        toolbar.tintColor = UIColor.darkGray
        let spaceLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let spaceRight = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        if navigationController == nil {
            toolbar.items = [goBackButton, spaceLeft, doneButton, spaceRight, goForwardButton]
        } else {
            toolbar.items = [goBackButton, spaceRight, goForwardButton]
        }
        return toolbar
    }()
    
    lazy var goBackButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleBack))
        item.image = UIImage(named: "goBack")
        return item
    }()
    
    lazy var goForwardButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleForward))
        item.image = UIImage(named: "goForward")
        return item
    }()
    
    lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleDone))
    }()
    
    public override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureSubViews()
        goBackButton.isEnabled = false
        goForwardButton.isEnabled = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        loadUrl()
    }
    
    func configureSubViews() {
        webView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
        view.addSubview(toolBar)
        toolBar.leftAnchor.constraint(equalTo: webView.leftAnchor).isActive = true
        toolBar.rightAnchor.constraint(equalTo: webView.rightAnchor).isActive = true
        if #available(iOS 11.0, *) {
            toolBar.bottomAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            toolBar.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        }
    }
    
    func loadUrl() {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        activityIndicator.isHidden = false
        activityIndicator.color = UIColor.blue
        activityIndicator.startAnimating()
        goBackButton.isEnabled = false
        goForwardButton.isEnabled = false
        webView.load(request)
    }
    
    public init(urlString: String, showNavigationButtons: Bool, delegate: F4SWebViewControllerDelegate?) {
        self.delegate = delegate
        self.urlString = urlString
        self.isNavigationAllowed = showNavigationButtons
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc func handleBack() { webView.goBack() }
    @objc func handleForward() { webView.goForward() }
    @objc func handleDone() { dismiss(animated: true, completion: nil)}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoForward
    }
}
