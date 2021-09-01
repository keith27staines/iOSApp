
import Foundation
import WorkfinderCommon
import WorkfinderUI

protocol ProjectApplyCoordinatorProtocol: AnyObject, ErrorHandlerProviderProtocol {
    func onCoverLetterWorkflowCancelled()
    func onModalFinished()
    func onTapApply()
}
