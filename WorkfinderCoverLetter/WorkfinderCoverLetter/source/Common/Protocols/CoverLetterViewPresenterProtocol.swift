
import WorkfinderCommon
import WorkfinderCoordinators

protocol CoverLetterViewPresenterProtocol {
    var view: CoverLetterViewProtocol? { get set }
    var isLetterComplete: Bool { get }
    var displayString: String { get }
    var fieldConsistencyError: WorkfinderError? { get }
    var attributedDisplayString: NSAttributedString { get }
    var primaryButtonTitle: String { get }
    func onViewDidLoad(view: CoverLetterViewProtocol)
    func onViewDidAppear()
    func loadData(completion: @escaping (Error?) -> Void)
    func onDidTapShowQuestionsList()
    func onDidTapField(name: String, completion: @escaping (Error?)->Void)
    func onDidCancel()
    func onDidTapPrimaryButton()
}
