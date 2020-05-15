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
    
    public func displayOptionalErrorIfNotNil(
        _ optionalError: Error?,
        parentCtrl: UIViewController,
        cancelHandler: (() -> Void)? = {},
        retryHandler: (() -> Void)?) {
        guard let error = optionalError else { return }
        guard let workfinderError = error as? WorkfinderError else {
            assertionFailure("Cannot convert error to WorkfinderError")
            return
        }
        displayWorkfinderError(workfinderError,
                               parentCtrl: parentCtrl,
                               cancelHandler: cancelHandler,
                               retryHandler: retryHandler)
    }
        
    func displayWorkfinderError(_ error: WorkfinderError,
                        parentCtrl: UIViewController,
                        cancelHandler: (() -> Void)?,
                        retryHandler: (() -> Void)?) {
        
        presentCancelRetryAlert(
            title: error.title,
            message: error.description,
            cancelHandler: cancelHandler,
            retryHandler: retryHandler,
            parentCtrl: parentCtrl)
    }

    public func displayMessage(title: String, message: String, parentCtrl: UIViewController) {
        alert.title = title
        alert.message = message
        parentCtrl.present(alert, animated: true) {}
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

}
