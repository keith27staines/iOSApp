
import Foundation
import WorkfinderCommon
import UIKit

protocol CompanyHostsSectionViewProtocol: class {
    func refresh()
}

protocol CompanyHostsSectionPresenterProtocol {
    var selectedHostRow: Int? { get }
    var isAssociationSelected: Bool { get }
    var selectedAssociation: ExpandedAssociation? { get }
    var numberOfRows: Int { get }
    var associationsTextModel: TextModel { get }
    func cellforRow(_ row: Int, in tableView: UITableView) -> UITableViewCell
    func onDidTapLinkedIn(for: ExpandedAssociation)
    func onDidTapHostCell(_ hostCell: HostLocationAssociationCell, atIndexPath indexPath: IndexPath)
    func onHostsDidLoad(_ hosts: [ExpandedAssociation])
    func onViewDidLoad(_ view: CompanyHostsSectionViewProtocol)
}

class CompanyHostsSectionPresenter: CompanyHostsSectionPresenterProtocol {
    
    private weak var view: CompanyHostsSectionViewProtocol?
    var numberOfRows: Int { return associations.count }
    var associationsTextModel: TextModel

    func cellforRow(_ row: Int, in tableView: UITableView) -> UITableViewCell {
        let association = associations[row]
        let state = associationsTextModel.expandableLabelStates[row]
        let hostCell = tableView.dequeueReusableCell(withIdentifier: HostLocationAssociationCell.reuseIdentifier) as! HostLocationAssociationCell
        hostCell.configureWithAssociation(
            association,
            summaryState: state,
            profileLinkTap: onDidTapLinkedIn,
            selectAction: { [weak self] tappedHost in
                self?.updateAssociationSelectionState(from: tappedHost)
            })
        return hostCell
    }
    
    var tappedLinkedin: ((ExpandedAssociation) -> Void)?
    
    func onDidTapLinkedIn(for association: ExpandedAssociation) {
        tappedLinkedin?(association)
    }
    var selectedHostRow: Int?
    func onDidTapHostCell(_ hostCell: HostLocationAssociationCell, atIndexPath indexPath: IndexPath) {
        selectedHostRow = indexPath.row
        let association = associations[indexPath.row]
        var summaryState = associationsTextModel.expandableLabelStates[indexPath.row]
        summaryState.isExpanded.toggle()
        associationsTextModel.expandableLabelStates[indexPath.row] = summaryState
        hostCell.configureWithAssociation(association, summaryState: summaryState, profileLinkTap: onDidTapLinkedIn, selectAction: updateAssociationSelectionState)
    }
    
    var isAssociationSelected: Bool { selectedAssociation != nil }
    
    var selectedAssociation: ExpandedAssociation? {
        return associations.first { (association) -> Bool in association.isSelected }
    }
    
    func updateAssociationSelectionState(from updatedAssociation: ExpandedAssociation) {
        if updatedAssociation.isSelected {
            for (index, association) in associations.enumerated() {
                if association.uuid == updatedAssociation.uuid {
                    updateAssociation(from: updatedAssociation)
                    continue
                }
                associations[index].isSelected = false
            }
        } else {
            updateAssociation(from: updatedAssociation)
        }
        view?.refresh()
    }
    
    private func updateAssociation(from updatedAssociation: ExpandedAssociation) {
        guard let index = (associations.firstIndex { (association) -> Bool in
            association.uuid == updatedAssociation.uuid
        }) else { return }
        associations[index] = updatedAssociation
    }
    
    init() {
        self.associations = []
        self.associationsTextModel = TextModel(associations: associations)
        onHostsDidLoad([])
    }
    
    func onViewDidLoad(_ view: CompanyHostsSectionViewProtocol) {
        self.view = view
    }
    
    var associations: [ExpandedAssociation] = []
    
    func onHostsDidLoad(_ associations: [ExpandedAssociation]) {
        self.associations = associations
        if associations.count == 1 { self.associations[0].isSelected = true }
        self.associationsTextModel = TextModel(associations: associations)
        view?.refresh()
    }
}
