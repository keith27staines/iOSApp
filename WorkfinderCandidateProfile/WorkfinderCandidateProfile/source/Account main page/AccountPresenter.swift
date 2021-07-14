//
//  AccountPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 08/04/2021.
//

import WorkfinderCommon

class AccountPresenter: BaseAccountPresenter {
    
    weak var accountViewController: AccountViewController?
    
    enum TableSection: Int, CaseIterable {
        case header
        case accountSections
        case socialMediaConnections
        case links
    }
    
    let links: [WorkfinderContentType] = [.about, .faqs, .terms, .privacyPolicy]
    let accountSections: [AccountSectionInfo] = [
        AccountSectionInfo(
            image: UIImage(named: "settings_icon"),
            title: "Account Settings",
            calculator: YourDetailsSectionProgressCalculator()
        ),
//        AccountSectionInfo(
//            image: UIImage(named: "settings_icon"),
//            title: "Account Preferences",
//            calculator: nil
//        ),
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
    
    var table: UITableView?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        table = tableView
        return TableSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableSection(rawValue: section) else { return 0 }
        switch section {
        case .header: return 1
        case .accountSections: return accountSections.count
        case .socialMediaConnections: return 1
        case .links: return links.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        let repo = UserRepository()
        let user = repo.loadUser()
        
        switch section {
        case .header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AMPHeaderCell.reuseIdentifier) as? AMPHeaderCell else { return UITableViewCell() }
            if UserRepository().isCandidateLoggedIn {
                cell.configureWith(
                    avatar: UIImage(named: "avatar"),
                    title: user.fullname,
                    initials: initialsFromFullName(user.fullname),
                    email: user.email,
                    onTap: nil
                )
            } else {
                cell.configureWith(
                    avatar: UIImage(named: "avatar"),
                    title: "Your Account",
                    initials: initialsFromFullName(user.fullname),
                    email: user.email,
                    onTap: coordinator?.showRegisterAndSignin
                )
            }
            return cell
        case .accountSections:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AMPAccountSectionCell.reuseIdentifier) as? AMPAccountSectionCell else { return UITableViewCell() }
            cell.configureWith(accountSections[indexPath.row])
            return cell
            
        case .socialMediaConnections:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SocialMediaCell.reuseIdentifier) as? SocialMediaCell else { return UITableViewCell() }
            cell.configureWithLinkedinDataConnection(linkedinConnection)
            cell.accessoryType = .disclosureIndicator
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
            accountViewController?.messageHandler.showLoadingOverlay()
            switch indexPath.row {
            case 0: coordinator?.showDetails()
            case 1: coordinator?.showPreferences()
            default: break
            }
        case .socialMediaConnections:
            if UserRepository().isCandidateLoggedIn {
                coordinator?.showLinkedinData()
            } else {
                guard let vc = accountViewController else { return }
                let alert = UIAlertController(title: "Sign in first", message: "You must sign into Workfinder before you can link your LinkedIn account", preferredStyle: .alert)
                let okaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okaction)
                vc.present(alert, animated: true, completion: nil)
            }

        case .links: coordinator?.presentContent(links[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let section = TableSection(rawValue: indexPath.section) else { return false }
        switch section {
        
        case .header: return false
        case .accountSections: return true
        case .socialMediaConnections: return true
        case .links: return true
        }
    }
}

protocol ProgressCalculatorProtocol: AnyObject {
    var progress: Float { get }
}

class YourDetailsSectionProgressCalculator: ProgressCalculatorProtocol {
    
    var repository: UserRepositoryProtocol = UserRepository()
    
    var progress: Float {
        let isLoggedIn = repository.isCandidateLoggedIn
        let candidate = repository.loadCandidate()
        let user = repository.loadUser()
        var total = isLoggedIn ? 1 : 0  // proxy for password
        var max = 1
        total += scoreForOptionalString(string: user.fullname)
        max += 1
        total += scoreForOptionalString(string: user.email)
        max += 1
        total += scoreForOptionalString(string: candidate.phone)
        max += 1
        total += scoreForOptionalString(string: candidate.dateOfBirth)
        max += 1
        total += scoreForOptionalString(string: candidate.postcode)
        max += 1
        total += scoreForOptionalCount(count: candidate.languages?.count)
        max += 1
        total += scoreForOptionalCount(count: candidate.gender?.count)
        max += 1
        total += scoreForOptionalCount(count: candidate.ethnicity?.count)
        max += 1
        total += scoreForOptionalCount(count: candidate.strongestSkills?.count)
        max += 1
        total += scoreForOptionalCount(count: candidate.personalAttributes?.count)
        max += 1
        return Float(total) / Float(max)
    }
    
    func scoreForOptionalString(string: String?) -> Int {
        guard let string = string, string.isEmpty == false else { return 0 }
        return 1
    }
    
    func scoreForOptionalCount(count: Int?) -> Int {
        guard let count = count, count > 0 else {return 0 }
        return 1
    }
    
}
