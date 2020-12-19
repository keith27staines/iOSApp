
import UIKit
import WorkfinderCommon
import WorkfinderUI

public enum LoadingOverlayStyle {
    case dark
    case light
    case transparent
}

public class HSUserMessageHandler {
    private var count: Int = 0
    weak public private (set) var messagePresenter: UIViewController?
    weak var view: UIView?
    
    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    var loadingOverlay: HSLoadingOverlay = HSLoadingOverlay()

    public convenience init(presenter: UIViewController) {
        self.init(view: presenter.view)
        self.messagePresenter = presenter
    }
    
    public init(view: UIView) {
        self.view = view
        let action = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alert.addAction(action)
    }
    
    public func displayOptionalErrorIfNotNil(
        _ optionalError: Error?,
        cancelHandler: @escaping (() -> Void) = {},
        retryHandler: (() -> Void)?) {
        guard let error = optionalError else { return }
        guard let workfinderError = error as? WorkfinderError else {
            assertionFailure("Cannot convert error to WorkfinderError")
            return
        }
        displayWorkfinderError(workfinderError,
                               cancelHandler: cancelHandler,
                               retryHandler: retryHandler)
    }
        
    func displayWorkfinderError(_ error: WorkfinderError,
                        cancelHandler: @escaping (() -> Void),
                        retryHandler: (() -> Void)?) {
        
        presentCancelRetryAlert(
            title: error.title,
            message: error.description,
            cancelHandler: cancelHandler,
            retryHandler: retryHandler)
    }

    public func displayMessage(title: String, message: String) {
        alert.title = title
        alert.message = message
        messagePresenter?.present(alert, animated: true) {}
    }

    public func presentEnableLocationInfo() {
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
        messagePresenter?.present(alert, animated: true, completion: nil)
    }

    public func showLoadingOverlay(style: LoadingOverlayStyle) {
        guard let view = view else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let loadingOverlay = self.loadingOverlay
            self.count += 1
            print("Adding overlay \(self.count)")
            if self.count > 1 { return }
            view.addSubview(loadingOverlay)
            loadingOverlay.frame = view.frame
            loadingOverlay.showOverlay(style: style)
        }
    }

    public func hideLoadingOverlay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Removing overlay \(self.count)")
            self.count -= 1
            if self.count <= 0 {
                self.loadingOverlay.hideOverlay()
            }
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
        cancelHandler: @escaping (() -> Void),
        retryHandler: (() -> Void)?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            cancelHandler()
        }
        alert.addAction(cancelAction)
        
        if let retryHandler = retryHandler {
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                retryHandler()
            }
            alert.addAction(retryAction)
        }
        
        messagePresenter?.present(alert, animated: true) {}
    }

}

