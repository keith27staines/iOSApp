//
//  AccountPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import WorkfinderCommon

class AccountPresenter: BaseAccountPresenter {
    
    enum TableSection: Int, CaseIterable {
        case header
        case accountSections
        case links
    }
    
    let links: [WorkfinderContentType] = [.about, .faqs, .terms, .privacyPolicy]
    let accountSections: [AccountSectionInfo] = [
        AccountSectionInfo(
            image: UIImage(named: "your_details_icon"),
            title: "Your Details",
            progress: 0.75
        ),
        AccountSectionInfo(
            image: UIImage(named: "settings_icon"),
            title: "Account Preferences",
            progress: 0
        ),
    ]
    
    var footerLabelText: String {
        return "\(memberSince)• \(version)"
    }
    
    private var memberSince: String {
        guard let dateString = user.created, dateString.isEmpty == false, let date = Date.workfinderDateStringToDate(dateString)
            else { return "" }
        
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return "Member since \(df.string(from: date)) "
    }
    
    private var version: String {
        var appVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
           appVersion = "v\(version)"
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
           appVersion += "(\(build))"
        }
        return appVersion
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { TableSection.allCases.count }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableSection(rawValue: section) else { return 0 }
        switch section {
        case .header: return 1
        case .accountSections: return accountSections.count
        case .links: return links.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        let repo = UserRepository()
        let user = repo.loadUser()
        let candidate = repo.loadCandidate()
        
        switch section {
        case .header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AMPHeaderCell.reuseIdentifier) as? AMPHeaderCell else { return UITableViewCell() }
            cell.configureWith(
                avatar: UIImage(named: "avatar"),
                fullName: candidate.fullName,
                initials: initialsFromFullName(candidate.fullName),
                email: user.email
            )
            return cell
        case .accountSections:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AMPAccountSectionCell.reuseIdentifier) as? AMPAccountSectionCell else { return UITableViewCell() }
            cell.configureWith(accountSections[indexPath.row])
            return cell
        
        case .links:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AMPLinksCell.reuseIdentifier) as? AMPLinksCell else { return UITableViewCell() }
            cell.configureWith(
                contentType: links[indexPath.row])
            return cell
        }
    }
    
    func initialsFromFullName(_ name: String?) -> String {
        guard let name = name, name.count > 0 else { return "" }
        let names = name.split(separator: " ")
        return names.reduce("") { (result, substring) -> String in
            return result + (String(substring.first ?? " "))
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = TableSection(rawValue: indexPath.section) else { return }
        switch section {
        case .header: return
        case .accountSections:
            
            switch indexPath.row {
            case 0: coordinator?.showDetails()
            case 1: coordinator?.showPreferences()
            default: break
            }

        case .links: coordinator?.presentContent(links[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let section = TableSection(rawValue: indexPath.section) else { return false }
        switch section {
        
        case .header: return false
        case .accountSections: return true
        case .links: return true
        }
    }
}
