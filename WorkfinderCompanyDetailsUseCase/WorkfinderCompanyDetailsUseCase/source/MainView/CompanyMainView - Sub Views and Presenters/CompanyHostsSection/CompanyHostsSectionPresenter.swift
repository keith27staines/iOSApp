
import Foundation
import WorkfinderCommon
import UIKit

protocol CompanyHostsSectionPresenterRepresentable: class {
    func refresh(from presenter: CompanyHostsSectionPresenterProtocol)
}

protocol CompanyHostsSectionPresenterProtocol {
    var numberOfRows: Int { get }
    var hostsSummaryModel: TextModel { get }
    func cellforRow(_ row: Int, in tableView: UITableView) -> UITableViewCell
    func onDidTapLinkedIn(for: Host)
    func onDidTapHostCell(_ hostCell: HostCell, atIndexPath indexPath: IndexPath)
    func onHostsDidLoad(_ hosts: [Host])
}

class CompanyHostsSectionPresenter: CompanyHostsSectionPresenterProtocol {
    private weak var view: CompanyHostsSectionPresenterRepresentable?
    private var hosts: [Host]
    var numberOfRows: Int { return hosts.count }
    var hostsSummaryModel: TextModel

    func cellforRow(_ row: Int, in tableView: UITableView) -> UITableViewCell {
        let host = hosts[row]
        let state = hostsSummaryModel.expandableLabelStates[row]
        let hostCell = tableView.dequeueReusableCell(withIdentifier: HostCell.reuseIdentifier) as! HostCell
        hostCell.configureWithHost(
            host,
            summaryState: state,
            profileLinkTap: onDidTapLinkedIn,
            selectAction: { [weak self] tappedHost in
                self?.updateHostSelectionState(from: tappedHost)
            })
        return hostCell
    }
    
    
    func onDidTapLinkedIn(for: Host) {
        
    }
    
    func onDidTapHostCell(_ hostCell: HostCell, atIndexPath indexPath: IndexPath) {
        let host = hosts[indexPath.row]
        var summaryState = hostsSummaryModel.expandableLabelStates[indexPath.row]
        summaryState.isExpanded.toggle()
        hostsSummaryModel.expandableLabelStates[indexPath.row] = summaryState
        hostCell.configureWithHost(host, summaryState: summaryState, profileLinkTap: onDidTapLinkedIn, selectAction: updateHostSelectionState)
    }
    
    var selectedHost: Host? {
        let host = hosts.first { (host) -> Bool in host.isSelected }
        return host
    }
    
    func updateHostSelectionState(from updatedHost: Host) {
        if updatedHost.isSelected {
            for (index, host) in hosts.enumerated() {
                if host.uuid == updatedHost.uuid {
                    updateHost(from: updatedHost)
                    continue
                }
                hosts[index].isSelected = false
            }
        } else {
            updateHost(from: updatedHost)
        }
        view?.refresh(from: self)
    }
    
    private func updateHost(from updatedHost: Host) {
        guard let index = (hosts.firstIndex { (host) -> Bool in
            host.uuid == updatedHost.uuid
        }) else { return }
        hosts[index] = updatedHost
    }
    
    init() {
        self.hosts = []
        self.hostsSummaryModel = TextModel(hosts: [])
        onHostsDidLoad([])
    }
    
    func onHostsDidLoad(_ hosts: [Host]) {
        self.hosts = hosts
        self.hostsSummaryModel = TextModel(hosts: hosts)
        view?.refresh(from: self)
    }
}
