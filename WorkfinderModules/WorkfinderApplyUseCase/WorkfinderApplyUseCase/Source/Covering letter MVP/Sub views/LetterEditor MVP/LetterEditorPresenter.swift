
import Foundation

protocol LetterEditorPresenterProtocol {
    func onViewDidLoad(view: LetterEditorViewProtocol)
    func onDidDismiss()
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func picklist(for indexPath: IndexPath) -> Picklist
    func showPicklist(_ picklist: Picklist)
}

class LetterEditorPresenter: LetterEditorPresenterProtocol {
    
    func showPicklist(_ picklist: Picklist) {
        coordinator?.showPicklist(picklist)
    }

    func picklist(for indexPath: IndexPath) -> Picklist {
        let type = Picklist.PicklistType(rawValue: indexPath.row/2)!
        return picklistsDictionary[type]!
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int { return Picklist.PicklistType.allCases.count * 2 }
    func numberOfSections() -> Int { return 1 }
    
    weak var coordinator: LetterEditorCoordinatorProtocol?
    weak var view: LetterEditorViewProtocol?
    let picklistsDictionary: PicklistsDictionary
    
    func onViewDidLoad(view: LetterEditorViewProtocol) {
        self.view = view
        view.refresh()
        for (_, picklist) in picklistsDictionary {
            picklist.fetchItems { (picklist, result) in
                view.refresh()
            }
        }
    }
    
    func onDidDismiss() {
        guard let view = view else { return }
        coordinator?.letterEditor(view: view, updatedPickLists: picklistsDictionary)
    }
    
    init(coordinator: LetterEditorCoordinatorProtocol, picklists: PicklistsDictionary) {
        self.coordinator = coordinator
        self.picklistsDictionary = picklists
    }
}
