
import Foundation
import UIKit

class MessageHandler {
    private var count: Int = 0
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
    
    func display(_ networkError: F4SNetworkError, parentCtrl: UIViewController, cancelHandler: (()->())? = nil, retryHandler: (() -> ())? = nil) {
        
        let title: String
        let message: String
        
        if networkError.retry {
            if networkError.httpStatusCode == 429 {
                title =  "The server is busy"
                message = "Please wait a minute or so and try again"
            } else {
                title =  "Workfinder needs a network connection"
                message = "Please make sure you have a good network connection and try again"
            }
        } else {
            title = "Workfinder could not complete an operation"
            message = "\(networkError.code): \(networkError.localizedDescription) attempting \(networkError.attempting ?? "the last action")"
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        if let cancelHandler = cancelHandler {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                cancelHandler()
            }
            alert.addAction(cancelAction)
        }
        if networkError.retry {
            if let retryHandler = retryHandler {
                let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                    retryHandler()
                }
                alert.addAction(retryAction)
            }
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            }
            alert.addAction(okAction)
        }

        parentCtrl.present(alert, animated: true) {}
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
        let alert = UIAlertController(title: "", message: NSLocalizedString("Please enable location services.", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertAction.Style.default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel) { _ in
            if parentCtrl is MapViewController {
                (parentCtrl as! MapViewController).displayDefaultSearch()
            }
        })
        parentCtrl.present(alert, animated: true, completion: nil)
    }

    func showLoadingOverlay(_ view: UIView, useLightOverlay: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            if (self?.count ?? 0) > 0 { return }
            MessageHandler.loadingOverlay = LoadingOverlay()
            view.addSubview(MessageHandler.loadingOverlay)
            MessageHandler.loadingOverlay.frame = view.frame
            self?.count += 1
            if useLightOverlay {
                MessageHandler.loadingOverlay.showLightOverlay()
            } else {
                MessageHandler.loadingOverlay.showOverlay()
            }
        }
    }

    func showLightLoadingOverlay(_ view: UIView) {
        showLoadingOverlay(view, useLightOverlay: true)
    }

    func hideLoadingOverlay() {
        DispatchQueue.main.async { [weak self] in
            self?.count -= 1
            MessageHandler.loadingOverlay.hideOverlay()
        }
    }
    
    func updateOverlayCaption(_ text: String) {
        DispatchQueue.main.async {
            MessageHandler.loadingOverlay.caption = text
        }
    }
}
