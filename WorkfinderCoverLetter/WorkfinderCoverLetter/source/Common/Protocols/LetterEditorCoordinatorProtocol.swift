
import WorkfinderCommon
import WorkfinderCoordinators

protocol LetterEditorCoordinatorProtocol: class {
    func onLetterEditorTapPrimaryButton()
    func onLetterEditorDismiss()
    func showPicklist(_ picklist: PicklistProtocol, completion: ((Error?) -> Void)? )
    func onLetterEditorDidUpdate()
}
