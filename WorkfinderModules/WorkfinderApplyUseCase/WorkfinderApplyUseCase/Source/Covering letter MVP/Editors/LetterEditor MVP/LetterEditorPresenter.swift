
import Foundation
import WorkfinderCommon

protocol LetterEditorPresenterProtocol {
    func onViewDidLoad(view: LetterEditorViewProtocol)
    func onDidDismiss()
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func picklist(for indexPath: IndexPath) -> PicklistProtocol
    func showPicklist(_ picklist: PicklistProtocol)
}

class LetterEditorPresenter: LetterEditorPresenterProtocol {
    
    func showPicklist(_ picklist: PicklistProtocol) {
        coordinator?.showPicklist(picklist)
    }

    func picklist(for indexPath: IndexPath) -> PicklistProtocol {
        return picklists[indexPath.row/2]
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int { return picklists.count * 2 }
    func numberOfSections() -> Int { return 1 }
    
    weak var coordinator: LetterEditorCoordinatorProtocol?
    weak var view: LetterEditorViewProtocol?
    let picklists: [PicklistProtocol]
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
    
    init(coordinator: LetterEditorCoordinatorProtocol, picklists: PicklistsDictionary) {
        self.coordinator = coordinator
        self.picklists = ([PicklistProtocol](picklists.values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
    }
}
