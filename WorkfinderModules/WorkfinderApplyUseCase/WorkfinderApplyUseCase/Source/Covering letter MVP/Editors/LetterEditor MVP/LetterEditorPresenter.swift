
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
        return picklists[indexPath.row/2]
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int { return picklists.count * 2 }
    func numberOfSections() -> Int { return 1 }
    
    weak var coordinator: LetterEditorCoordinatorProtocol?
    weak var view: LetterEditorViewProtocol?
    let picklists: [Picklist]
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
        self.picklists = ([Picklist](picklists.values)).sorted(by: { (p1, p2) -> Bool in
            p1.type.rawValue < p2.type.rawValue
        })
    }
}
