
import Foundation
import UIKit

class MessageHandler {
    static let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    static var loadingOverlay: LoadingOverlay = LoadingOverlay()

    class var sharedInstance: MessageHandler {
        struct Static {
            static let instance: MessageHandler = MessageHandler()
        }
        return Static.instance
    }

    init() {
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            // Put here any code that you would like to execute when
            // the user taps that OK button (may be empty in your case if that's just
            // an informative alert)
        }
        MessageHandler.alert.addAction(action)
    }

    func display(_ errorMessage: String, parentCtrl: UIViewController) {
        switch errorMessage
        {

        case "Deserialization error":
            MessageHandler.alert.title = ""
            MessageHandler.alert.message = NSLocalizedString("An error has occurred. Please try again", comment: "")
            parentCtrl.present(MessageHandler.alert, animated: true) {}
            break

        case "No Internet Connection.":
            MessageHandler.alert.title = NSLocalizedString("No Data Connectivity", comment: "")
            MessageHandler.alert.message = NSLocalizedString("You appear to be offline at the moment. Please try again later when you have a working internet connection.", comment: "")
            parentCtrl.present(MessageHandler.alert, animated: true) {}
            break
        default:
            MessageHandler.alert.title = ""
            MessageHandler.alert.message = errorMessage
            parentCtrl.present(MessageHandler.alert, animated: true) {}
            break
        }
    }

    func display(_ errorMessage: CallError, parentCtrl: UIViewController) {
        MessageHandler.alert.title = errorMessage.appErrorMessageTitle
        MessageHandler.alert.message = errorMessage.appErrorMessage
        parentCtrl.present(MessageHandler.alert, animated: true) {}
    }

    func displayWithTitle(_ title: String, _ errorMessage: String, parentCtrl: UIViewController) {
        switch errorMessage
        {
        default:
            MessageHandler.alert.message = errorMessage
            MessageHandler.alert.title = title
            parentCtrl.present(MessageHandler.alert, animated: true) {}
        }
    }

    func presentEnableLocationInfo(parentCtrl: UIViewController) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Please enable location services.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertActionStyle.default) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { _ in
            if parentCtrl is MapViewController {
                (parentCtrl as! MapViewController).displayDefaultSearch()
            }
        })
        parentCtrl.present(alert, animated: true, completion: nil)
    }

    func showLoadingOverlay(_ view: UIView) {
        MessageHandler.loadingOverlay = LoadingOverlay()
        view.addSubview(MessageHandler.loadingOverlay)
        MessageHandler.loadingOverlay.frame = view.frame
        MessageHandler.loadingOverlay.showOverlay()
    }

    func showLightLoadingOverlay(_ view: UIView) {
        MessageHandler.loadingOverlay = LoadingOverlay()
        view.addSubview(MessageHandler.loadingOverlay)
        MessageHandler.loadingOverlay.frame = view.frame
        MessageHandler.loadingOverlay.showLightOverlay()
    }

    func hideLoadingOverlay() {
        MessageHandler.loadingOverlay.hideOverlay()
    }
}