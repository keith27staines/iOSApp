import Foundation
import WorkfinderCommon

public class WorkfinderUI {
    
    let bundle = Bundle(identifier: "com.f4s.WorkfinderUI")
    
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

