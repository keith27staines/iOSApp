
import WorkfinderCommon
import WorkfinderCoordinators

protocol CoverLetterViewPresenterProtocol {
    var view: CoverLetterViewProtocol? { get set }
    var isLetterComplete: Bool { get }
    var displayString: String { get }
    var attributedDisplayString: NSAttributedString { get }
    var primaryButtonTitle: String { get }
    func onViewDidLoad(view: CoverLetterViewProtocol)
    func loadData(completion: @escaping (Error?) -> Void)
    func onDidTapSelectOptionsButton()
    func onDidCancel()
    func onDidTapPrimaryButton()
}
