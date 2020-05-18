
import WebKit

public protocol WebViewControllerDelegate : class {
    func webViewControllerDidFinish(_ vc: WebViewController)
}

public class WebViewController: UIViewController, WKNavigationDelegate {

    let url: URL?
    let isNavigationAllowed: Bool
    weak var delegate: WebViewControllerDelegate?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
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
        let item = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleBack))
        item.image = UIImage(named: "goBack")
        item.tintColor = WorkfinderColors.primaryColor
        return item
    }()
    
    lazy var goForwardButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Forward", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleForward))
        item.image = UIImage(named: "goForward")
        item.tintColor = WorkfinderColors.primaryColor
        return item
    }()
    
    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleDone))
        button.tintColor = WorkfinderColors.primaryColor
        return button
    }()
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureSubViews()
        goBackButton.isEnabled = false
        goForwardButton.isEnabled = false
    }
    
    public override func viewDidAppear(_ animated: Bool) { loadUrl() }
    
    func configureSubViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(webView)
        view.addSubview(toolBar)
        webView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: toolBar.topAnchor, trailing: guide.trailingAnchor)
        toolBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        webView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
    }
    
    func loadUrl() {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        activityIndicator.isHidden = false
        activityIndicator.color = UIColor.blue
        activityIndicator.startAnimating()
        goBackButton.isEnabled = false
        goForwardButton.isEnabled = false
        webView.load(request)
    }
    
    public convenience init(urlString: String,
                showNavigationButtons: Bool,
                delegate: WebViewControllerDelegate?) {
        
        self.init(url: URL(string: urlString),
                  showNavigationButtons: showNavigationButtons,
                  delegate: delegate)
    }
    
    public init(url: URL?, showNavigationButtons: Bool, delegate: WebViewControllerDelegate?) {
        self.delegate = delegate
        self.url = url
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
