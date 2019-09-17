import UIKit
import WorkfinderCommon

public class ContentViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func doneTapped(_ sender: Any) {
        dismissPage()
    }
    
    var contentType: F4SContentType?
    var url: String?
    var dismissByPopping: Bool = false
    var contentService: F4SContentServiceProtocol!

    override public func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearance()
        getContent()
    }
    
    var didChangeNavigationBarVisibility: Bool = false

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.isNavigationBarHidden = false
            didChangeNavigationBarVisibility = true
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        if didChangeNavigationBarVisibility {
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
        if let navigationController = navigationController, dismissByPopping == true {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - calls
extension ContentViewController {
    func getContent() {
        if self.contentType == .company {
            sharedUserMessageHandler.showLightLoadingOverlay(self.webView)
            if let companyUrl = url {
                self.loadURL(url: companyUrl)
                return
            }
        }
        sharedUserMessageHandler.showLightLoadingOverlay(self.webView)
        contentService.getContent { [weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                guard let contentType = strongSelf.contentType else { return }
                switch result {
                case .error(let error):
                    sharedUserMessageHandler.hideLoadingOverlay()
                    sharedUserMessageHandler.display(error, parentCtrl: strongSelf)
                case .success(let contentDescriptors):
                    guard let index = contentDescriptors.firstIndex(where: { (descriptor) -> Bool in descriptor.slug == contentType }) else {
                        sharedUserMessageHandler.hideLoadingOverlay()
                        print("No url for \(contentType)")
                        return
                    }
                    guard let contentUrl = contentDescriptors[index].url else {
                        sharedUserMessageHandler.hideLoadingOverlay()
                        print("No url for\(contentType)")
                        return
                    }
                    strongSelf.loadURL(url: contentUrl)
                }
            }
        }
    }
}

// MARK: - UIWebViewDelegate
extension ContentViewController: UIWebViewDelegate {
    public func webViewDidFinishLoad(_: UIWebView) {
        self.webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.webView.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.webView.stringByEvaluatingJavaScript(from: "window.scroll(0,0)")
        sharedUserMessageHandler.hideLoadingOverlay()
    }

    public func webView(_: UIWebView, didFailLoadWithError error: Error) {
        sharedUserMessageHandler.hideLoadingOverlay()
    }
}
