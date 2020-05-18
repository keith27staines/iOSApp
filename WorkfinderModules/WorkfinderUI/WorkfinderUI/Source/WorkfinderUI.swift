import Foundation
import WorkfinderCommon

public class WorkfinderUI {
    
    let bundle = Bundle(identifier: "com.workfinder.WorkfinderUI")
    
    public init() {}
}

public extension UIViewController {
    func openLinkInWebView(_ remoteLink: RemoteLinks) {
        let urlString = remoteLink.rawValue
        let webview = WebViewController(urlString: urlString, showNavigationButtons: true, delegate: nil)
        present(webview, animated: true, completion: nil)
    }

}

