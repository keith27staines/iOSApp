

import Foundation
import WorkfinderCommon

class CompanyDetailTableDataSource: NSObject, UITableViewDataSource {
    
    unowned let companyViewModel: CompanyViewModel
    let sectionDescriptorsModel: SectionDescriptorsModel
    var hosts: [F4SHost] { return companyViewModel.hosts }
    lazy var textModel: TextModel = {
        return TextModel(hosts: self.hosts)
    }()
    
    public init(companyViewModel: CompanyViewModel, sectionDescriptorsModel: SectionDescriptorsModel) {
        self.companyViewModel = companyViewModel
        self.sectionDescriptorsModel = sectionDescriptorsModel
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostCell") as! HostCell
        let host = hosts[indexPath.row]
        let summaryState = textModel.expandableLabelStates[indexPath.row]
        cell.configureWithHost(host, summaryState: summaryState ,profileLinkTap: profileLinkTap)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HostCell
        let host = hosts[indexPath.row]
        var summaryState = textModel.expandableLabelStates[indexPath.row]
        summaryState.isExpanded.toggle()
        textModel.expandableLabelStates[indexPath.row] = summaryState
        cell.configureWithHost(host, summaryState: summaryState, profileLinkTap: profileLinkTap)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func profileLinkTap(host: F4SHost) {
        companyViewModel.didTapLinkedIn(for: host)
    }
}
