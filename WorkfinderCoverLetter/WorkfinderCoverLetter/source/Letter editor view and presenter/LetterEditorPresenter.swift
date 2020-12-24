
import Foundation
import WorkfinderCommon

class LetterEditorPresenter: LetterEditorPresenterProtocol {
    weak var coordinator: LetterEditorCoordinatorProtocol?
    weak var view: LetterEditorViewController?
    var consistencyError: WorkfinderError?
    var appearanceCount: Int = 0
    let logic: CoverLetterLogic
    let log: F4SAnalytics
    var showingPicklist: PicklistProtocol?
    
    var additionalInformationPicklists: [PicklistProtocol] {
        switch logic.flowType {
        case .projectApplication:
            if appearanceCount < 2 {
                return []
            } else {
                return logic.additionalInformationPicklists()
            }
        case .passiveApplication:
            return logic.additionalInformationPicklists()
        }
    }
    
    var coverLetterPicklists: [PicklistProtocol] {
        switch logic.flowType {
        case .projectApplication:
            if appearanceCount < 2 {
                return logic.nonOptionalSortedCoverLetterPicklists()
            } else {
                return logic.sortedCoverLetterPicklists()
            }
        case .passiveApplication:
            return logic.sortedCoverLetterPicklists()
        }
    }
    
    func showPicklist(_ picklist: PicklistProtocol) {
        showingPicklist = picklist
        log.track(.question_opened(picklist.type))
        appearanceCount -= 1
        coordinator?.showPicklist(picklist, completion: nil)
    }
    
    func onViewWillRefresh() {
        consistencyCheck()
    }
    
    var isDisplayingAllQuestions: Bool = false
    var textForToggleAllQuestionsButton: String? {
        let isHidingQuestions = logic.shouldHideAnsweredQuestions
        return isHidingQuestions ? "Show all questions" : "Hide answered questions"
    }
    func toggleShowAllQuestions() {
        isDisplayingAllQuestions.toggle()
        logic.shouldHideAnsweredQuestions.toggle()
    }

    func picklist(for indexPath: IndexPath) -> PicklistProtocol {
        switch indexPath.section {
        case 0:
            return coverLetterPicklists[indexPath.row]
        default:
            return logic.additionalInformationPicklists()[indexPath.row]
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0: return coverLetterPicklists.count
        case 1: return additionalInformationPicklists.count
        default: return 0
        }
    }
    
    func numberOfSections() -> Int {
        additionalInformationPicklists.count == 0 ? 1 : 2
    }
    
    func headingForSection(_ section: Int) -> (String, String) {
        switch section {
        case 0:
            return ("Please provide all the information required to complete your cover letter", "(fields in this section are required)")
        case 1:
            return ("The below fields are optional but could help in finding you relevant role matches", "")
        default:
            return ("","")
        }
    }

    func onViewDidLoad(view: LetterEditorViewController) {
        self.view = view
        view.refresh()
    }

    func onViewDidAppear() {
        if let picklist = showingPicklist {
            log.track(.question_closed(picklist.type, picklist.isPopulated))
        }
        log.track(.letter_editor)
        appearanceCount += 1
        consistencyCheck()
        coordinator?.onLetterEditorDidUpdate()
    }
    
    func loadData(completion: @escaping (Error?) -> Void ) {
        logic.load { [weak self] (optionalError) in
            guard let self = self else { return }
            if let error = optionalError {
                completion(error)
                return
            }
            for picklist in self.logic.allPicklists() {
                guard !picklist.isLoaded else { continue }
                picklist.fetchItems { (picklist, result) in
                    switch result {
                    case .success(_):
                        self.consistencyCheck()
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
        }
    }
    
    func consistencyCheck() {
        consistencyError = logic.consistencyCheck()
    }
    
    func onTapPrimaryButton() {
        coordinator?.onLetterEditorTapPrimaryButton()
    }
    
    func onDismiss() {
        coordinator?.onLetterEditorDismiss()
    }
    
    init(coordinator: LetterEditorCoordinatorProtocol,
         logic: CoverLetterLogic,
         log: F4SAnalytics) {
        self.coordinator = coordinator
        self.logic = logic
        self.log = log
    }
}

