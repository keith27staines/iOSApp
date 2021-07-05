//
//  OAuthLinkedin.swift
//  WorkfinderLinkedinSync
//
//  Created by Keith on 15/06/2021.
//

import UIKit
import WebKit
import WorkfinderUI
import WorkfinderCommon

protocol OAuthLinkedinCoordinator: AnyObject {
    func oauthLinkedinDidComplete(_ cancelled: Bool)
}

class OAuthLinkedinViewController: UIViewController {
    private let callBack: String = "ios-auth-callback"
    private let host: String?
    private lazy var url: URL? = {
        let host = self.host ?? "workfinder.com"
        let url = "https://\(host)/auth/linkedin_oauth2/login/?process=connect&next=%2f\(callBack)"
        return URL(string: url)
    }()
    
    weak var coordinator: OAuthLinkedinCoordinator?
    private(set) var isComplete: Bool = false
    
    private var callbackNavigation: WKNavigation?
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = false
        view.allowsLinkPreview = false
        view.navigationDelegate = self
        return view
    }()
    
    lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Connect LinkedIn")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelButtonTapped))
        navItem.rightBarButtonItem = doneItem

        navBar.setItems([navItem], animated: false)
        navBar.isTranslucent = false
        navBar.barTintColor = WorkfinderColors.primaryColor
        navBar.tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        return navBar
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        let cancelled = !isComplete
        if isMovingFromParent && cancelled {
            onComplete()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        load()
    }
    
    private func load() {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func onComplete() {
        //removeCookies()
        dismiss(animated: true, completion: nil)
        coordinator?.oauthLinkedinDidComplete(!isComplete)
    }
    
    init(host: String, coordinator: OAuthLinkedinCoordinator) {
        self.coordinator = coordinator
        self.host = host
        super.init(nibName: nil, bundle: nil)
        configureViews()
        modalPresentationStyle = .overFullScreen
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(navigationBar)
        view.addSubview(webView)
        navigationBar.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor)
        webView.anchor(top: navigationBar.bottomAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor)
    }
    
    @objc func cancelButtonTapped() {
        onComplete()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OAuthLinkedinViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url, url.path.contains(callBack) else { return }
        self.callbackNavigation = navigation
        isComplete = true
        onComplete()
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        let cancel = (navigationAction.request.url?.absoluteString ?? "").contains("user_cancelled_login")
        if cancel { onComplete() }
    }
}
