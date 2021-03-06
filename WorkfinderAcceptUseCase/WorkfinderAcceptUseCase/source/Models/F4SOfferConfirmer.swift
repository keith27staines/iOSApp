
import Foundation
import WorkfinderCommon
import WorkfinderUI

class F4SOfferConfirmer {
    
    var placementService: F4SOfferProcessingServiceProtocol
    var messageHandler: UserMessageHandler
    let placement: F4STimelinePlacement
    let sender: UIViewController
    var logger: F4SAnalyticsAndDebugging?
    
    init(messageHandler: UserMessageHandler,
         placementService: F4SOfferProcessingServiceProtocol,
         placement: F4STimelinePlacement,
         sender: UIViewController,
         logger: F4SAnalyticsAndDebugging? = nil) {
        self .messageHandler = messageHandler
        self.placementService = placementService
        self.placement = placement
        self.sender = sender
        self.logger = logger
    }
    
    func confirmOffer(success: @escaping (() -> Void) ) {
        
        messageHandler.showLoadingOverlay(sender.view)
        placementService.confirmPlacement(placement: placement, completion: {
            (confirmResult) in
            DispatchQueue.main.async { [weak self] in
                self?.messageHandler.hideLoadingOverlay()
                self?.handleConfirmResult(confirmResult, success: success)
            }
        })
    }
    
    func handleConfirmResult(_ result: F4SNetworkResult<Bool>, success: @escaping () -> Void) {
        switch  result {
        case .error(let error):
            if error.retry {
                messageHandler.display(error, parentCtrl: sender, cancelHandler: nil, retryHandler: {
                    self.confirmOffer(success: success)
                })
            } else {
                messageHandler.display(error, parentCtrl: sender)
            }
        case .success(let confirmed):
            if confirmed == true {
                success()
            } else {
                logger?.error(message: "confirm placement failed with an unexpected error in the response body", functionName: #function, fileName: #file, lineNumber: #line)
            }
        }
    }
}
