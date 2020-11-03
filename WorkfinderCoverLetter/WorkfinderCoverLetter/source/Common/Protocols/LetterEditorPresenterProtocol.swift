
import WorkfinderCommon
import WorkfinderCoordinators

protocol LetterEditorPresenterProtocol {
    var consistencyError: WorkfinderError? { get }
    var textForToggleAllQuestionsButton: String? { get }
    func toggleShowAllQuestions()
    func onViewDidLoad(view: LetterEditorViewController)
    func onViewDidAppear()
    func onViewWillRefresh()
    func loadData(completion: @escaping (Error?) -> Void )
    func onDismiss()
    func onTapPrimaryButton()
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func picklist(for indexPath: IndexPath) -> PicklistProtocol
    func showPicklist(_ picklist: PicklistProtocol)
    func headingForSection(_ section: Int) -> (String, String)
}
