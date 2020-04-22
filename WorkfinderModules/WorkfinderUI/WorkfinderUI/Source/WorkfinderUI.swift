import Foundation
import WorkfinderCommon

public class WorkfinderUI {
    
    let bundle = Bundle(identifier: "com.workfinder.WorkfinderUI")
    
    public init() {}
    
    public func makeWebContentViewController(
        contentType: F4SContentType,
        dismissByPopping: Bool) -> ContentViewController {
        let storyboard = UIStoryboard(name: "Content", bundle: bundle)
        let contentViewController = storyboard.instantiateViewController(withIdentifier: "ContentViewCtrl") as! ContentViewController
        contentViewController.contentType = contentType
        contentViewController.dismissByPopping = true
        //contentViewController.contentService = contentService
        return contentViewController
    }
}

public extension UIViewController {
    func openLinkInWebView(_ remoteLink: RemoteLinks) {
        let urlString = remoteLink.rawValue
        let webview = F4SWebViewController(urlString: urlString, showNavigationButtons: true, delegate: nil)
        present(webview, animated: true, completion: nil)
    }

}

