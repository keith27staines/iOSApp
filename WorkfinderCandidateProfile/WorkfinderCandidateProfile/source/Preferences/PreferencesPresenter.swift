//
//  PreferencesPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import WorkfinderCommon

class PreferencesPresenter: BaseAccountPresenter {
    
    enum TableSection: Int, CaseIterable {
        case appNotifications
        case marketingEmails
        case removeAccount
        
        var title: String {
            switch self {
            case .appNotifications: return "App Notifications"
            case .marketingEmails: return "Marketing Emails"
            case .removeAccount: return "Remove Account"
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { TableSection.allCases.count }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableSection(rawValue: section) else { return 0 }
        switch section {
        case .appNotifications: return areNotificationsDisabled ? 2 : 1
        case .marketingEmails: return 1
        case .removeAccount: return 1
        }
    }
    
    private var areNotificationsDisabled: Bool {
        return true
    }
    
    private func getEnableNotificationsCell(_ table: UITableView) -> UITableViewCell {
        return table.dequeueReusableCell(withIdentifier: EnableNotificationsCell.reuseIdentifier) as? EnableNotificationsCell ??  UITableViewCell()
    }
    
    private func getNotificationControlsCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: NotificationControlsCell.reuseIdentifier) as? NotificationControlsCell else { return  UITableViewCell() }
        cell.configureWith(candidate: candidate)
        return cell
    }
    
    private func getMarketingEMailCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: MarketingEmailCell.reuseIdentifier) as? MarketingEmailCell else { return  UITableViewCell() }
        return cell
    }
    
    private func getRemoveAccountCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: RemoveAccountCell.reuseIdentifier) as? RemoveAccountCell else { return  UITableViewCell() }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        let repo = UserRepository()
        let user = repo.loadUser()
        let candidate = repo.loadCandidate()
        
        switch section {
        case .appNotifications:
            switch indexPath.row {
            case 0:
                if areNotificationsDisabled {
                    return getEnableNotificationsCell(tableView)
                } else {
                    return getNotificationControlsCell(tableView)
                }
            case 1: return getNotificationControlsCell(tableView)
            default: return UITableViewCell()
            }
        case .marketingEmails:
            return getMarketingEMailCell(tableView)
        
        case .removeAccount:
            return getRemoveAccountCell(tableView)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = TableSection(rawValue: indexPath.section) else { return }
        switch section {
        case .appNotifications: return
        case .marketingEmails: return
        case .removeAccount: return
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let section = TableSection(rawValue: indexPath.section) else { return false }
        switch section {
        case .appNotifications: return true
        case .marketingEmails: return true
        case .removeAccount: return true
        }
    }
}

