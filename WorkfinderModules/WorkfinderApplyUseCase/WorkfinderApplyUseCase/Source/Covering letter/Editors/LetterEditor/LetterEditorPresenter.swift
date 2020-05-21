
import Foundation
import WorkfinderCommon

protocol LetterEditorPresenterProtocol {
    func onViewDidLoad(view: LetterEditorViewProtocol)
    func onDidDismiss()
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func picklist(for indexPath: IndexPath) -> PicklistProtocol
    func showPicklist(_ picklist: PicklistProtocol)
    func titleForSection(_ section: Int) -> (String, String)
}

class LetterEditorPresenter: LetterEditorPresenterProtocol {
    weak var coordinator: LetterEditorCoordinatorProtocol?
    weak var view: LetterEditorViewProtocol?
    let picklists: [PicklistProtocol]
    let additionalInformation: AdditionalInformationPresenter
    func showPicklist(_ picklist: PicklistProtocol) {
        coordinator?.showPicklist(picklist)
    }

    func picklist(for indexPath: IndexPath) -> PicklistProtocol {
        let picklistIndex = indexPath.row / 2
        switch indexPath.section {
        case 0:
            return picklists[picklistIndex]
        default:
            return additionalInformation.picklistForRow(picklistIndex)
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return picklists.count * 2
        default:
            return additionalInformation.numberOfRows() * 2
        }
    }
    
    func numberOfSections() -> Int {
        return additionalInformation.numberOfRows() == 0 ? 1 : 2
    }
    
    func titleForSection(_ section: Int) -> (String, String) {
        switch section {
        case 0:
            return ("Information required to complete your cover letter", "(fields in this section are required)")
        default:
            return ("Additional information that might help a host select you", "(fields in this section are optional)")
        }
    }

    func onViewDidLoad(view: LetterEditorViewProtocol) {
        self.view = view
        view.refresh()
        for picklist in picklists {
            picklist.fetchItems { (picklist, result) in
                view.refresh()
            }
        }
    }
    
    func onDidDismiss() {
        guard let view = view else { return }
        coordinator?.letterEditorDidComplete(view: view)
    }
    
    init(coordinator: LetterEditorCoordinatorProtocol,
         coverLetterpicklists: PicklistsDictionary,
         allPicklists: PicklistsDictionary) {
        self.coordinator = coordinator
        self.picklists = ([PicklistProtocol](coverLetterpicklists.values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
        self.additionalInformation = AdditionalInformationPresenter(
            coverLetterPicklists: coverLetterpicklists,
            allPicklists: allPicklists)
    }
}

class AdditionalInformationPresenter {
    
    let extraPicklists: [PicklistProtocol]
    let sectionTitle = "Additional information (optional)"
    
    init(coverLetterPicklists:PicklistsDictionary, allPicklists: PicklistsDictionary) {
        let skillsPicklist = allPicklists[.skills]
        let attributesPicklist = allPicklists[.attributes]
        let skillsAreIncludedInLetter: Bool = coverLetterPicklists[.skills] != nil
        let attributesAreIncludedInLetter: Bool = coverLetterPicklists[.attributes] != nil
        var extraPicklists = PicklistsDictionary()
        if !skillsAreIncludedInLetter { extraPicklists[.skills] = skillsPicklist }
        if !attributesAreIncludedInLetter { extraPicklists[.attributes] = attributesPicklist }
        self.extraPicklists = ([PicklistProtocol](extraPicklists.values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
    }
    
    func numberOfRows() -> Int {
        return extraPicklists.count
    }
    
    func picklistForRow(_ row: Int) -> PicklistProtocol {
        return extraPicklists[row]
    }
    
    
}
