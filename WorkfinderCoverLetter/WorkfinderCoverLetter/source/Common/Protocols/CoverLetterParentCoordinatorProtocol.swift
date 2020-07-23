
import WorkfinderCommon
import WorkfinderCoordinators

public protocol CoverLetterParentCoordinatorProtocol: Coordinating {
    var coverLetterPrimaryButtonText: String { get }
    func coverLetterDidCancel()
    func coverLetterCoordinatorDidComplete(coverLetterText: String, picklistsDictionary: PicklistsDictionary)
}
