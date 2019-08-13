import WorkfinderCommon
import UIKit

public let sharedUserMessageHandler = UserMessageHandler()

public class UserMessageHandler {
    
    private var count: Int = 0
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    var loadingOverlay: LoadingOverlay = LoadingOverlay()

    public init() {
        let action = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alert.addAction(action)
    }

    public func displayAlertFor(_ errorMessage: String, parentCtrl: UIViewController) {
        switch errorMessage
        {

        case "Deserialization error":
            alert.title = ""
            alert.message = NSLocalizedString("An error has occurred. Please try again", comment: "")
            parentCtrl.present(alert, animated: true) {}
            break

        case "No Internet Connection.":
            alert.title = NSLocalizedString("No Data Connectivity", comment: "")
            alert.message = NSLocalizedString("You appear to be offline at the moment. Please try again later when you have a working internet connection.", comment: "")
            parentCtrl.present(alert, animated: true) {}
            break
        default:
            alert.title = ""
            alert.message = errorMessage
            parentCtrl.present(alert, animated: true) {}
            break
        }
    }
    
    public func displayCancelRetryAlertFor(_ networkError: WEXNetworkError,
                                           parentCtrl: UIViewController,
                                           cancelHandler: (() -> Void)? = nil,
                                           retryHandler: (() -> Void)? = nil) {
        
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
            var httpStatus: String
            if let code = networkError.httpStatusCode {
                httpStatus = String(code)
            } else {
                httpStatus = "Unknown error"
            }
            
            message = "\(httpStatus): \(networkError.localizedDescription) attempting \(networkError.attempting ?? "the last action")"
        }
        
        presentCancelRetryAlert(
            title: title,
            message: message,
            cancelHandler: cancelHandler,
            retryHandler: retryHandler,
            parentCtrl: parentCtrl)
    }

    
    public func displayCancelRetryAlertFor(_ error: WEXError,
                        parentCtrl: UIViewController,
                        cancelHandler: (() -> Void)? = nil,
                        retryHandler: (() -> Void)? = nil) {
        if let networkError = error as? WEXNetworkError {
            displayCancelRetryAlertFor(networkError, parentCtrl: parentCtrl, cancelHandler: cancelHandler, retryHandler: retryHandler)
            return
        }
        
        presentCancelRetryAlert(
            title: NSLocalizedString("A problem occurred", comment: ""),
            message: error.localizedDescription,
            cancelHandler: cancelHandler,
            retryHandler: retryHandler,
            parentCtrl: parentCtrl)
    }
    
    fileprivate func presentCancelRetryAlert(
        title: String,
        message: String,
        cancelHandler: (() -> Void)?,
        retryHandler: (() -> Void)?,
        parentCtrl: UIViewController) {
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
        if let retryHandler = retryHandler {
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                retryHandler()
            }
            alert.addAction(retryAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            }
            alert.addAction(okAction)
        }
        
        parentCtrl.present(alert, animated: true) {}
    }
    
    public func display(_ networkError: F4SNetworkError,
                        parentCtrl: UIViewController,
                        cancelHandler: (() -> Void)? = nil,
                        retryHandler: (() -> Void)? = nil) {
        
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

        presentCancelRetryAlert(
            title: title,
            message: message,
            cancelHandler: cancelHandler,
            retryHandler: retryHandler,
            parentCtrl: parentCtrl)
    }

    public func displayWithTitle(_ title: String, _ errorMessage: String, parentCtrl: UIViewController) {
        switch errorMessage
        {
        default:
            alert.message = errorMessage
            alert.title = title
            parentCtrl.present(alert, animated: true) {}
        }
    }

    public func presentEnableLocationInfo(parentCtrl: UIViewController) {
        let alert = UIAlertController(
            title: "", message: NSLocalizedString("Please enable location services.", comment: ""),
            preferredStyle: UIAlertController.Style.alert)
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Settings", comment: ""),
                          style: UIAlertAction.Style.default)
            { _ in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel) { _ in
        })
        parentCtrl.present(alert, animated: true, completion: nil)
    }

    public func showLoadingOverlay(_ view: UIView, useLightOverlay: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let loadingOverlay = strongSelf.loadingOverlay
            if strongSelf.count > 0 { return }
            view.addSubview(loadingOverlay)
            loadingOverlay.frame = view.frame
            self?.count += 1
            if useLightOverlay {
                loadingOverlay.showLightOverlay()
            } else {
                loadingOverlay.showOverlay()
            }
        }
    }

    public func showLightLoadingOverlay(_ view: UIView) {
        showLoadingOverlay(view, useLightOverlay: true)
    }

    public func hideLoadingOverlay() {
        DispatchQueue.main.async { [weak self] in
            self?.count -= 1
            self?.loadingOverlay.hideOverlay()
        }
    }
    
    public func updateOverlayCaption(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingOverlay.caption = text
        }
    }
}
