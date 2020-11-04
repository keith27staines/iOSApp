
import WorkfinderCommon
import WorkfinderUI

protocol CoverletterCoordinatorProtocol: AnyObject {
    func onCoverLetterTapPrimaryButton()
    func onCoverLetterDismiss()
    func onCoverLetterTapEdit()
    func onCoverLetterTapField(name: String, completion: @escaping (Error?) -> Void) 
}
