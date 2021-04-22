//
//  PreferencesPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import WorkfinderCommon
import UserNotifications
import WorkfinderServices

class PreferencesPresenter: BaseAccountPresenter {
    
    var viewController: PreferencesViewController?
    
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
    
    private weak var tableView: UITableView?
    private var isLoggedIn: Bool { UserRepository().isCandidateLoggedIn }
    private var isPushNotificationsEnabled: Bool = false
    private var isShowingOpenIOSSettings: Bool {
        guard isLoggedIn else { return false }
        return !isPushNotificationsEnabled
    }
    
    lazy private var notificationPreferences: NotificationPreferences = {
        NotificationPreferences(
            isDirty: false,
            isEnabled: isPushNotificationsEnabled,
            allowApplicationUpdates: true,
            allowInterviewUpdates: true,
            allowRecommendations: true
        )
    }()
    
    lazy private var emailPreferences: EmailPreferences = {
        EmailPreferences(
            isDirty: false,
            isEnabled: isLoggedIn,
            allowMarketingEmails: true,
            preferencesPresenter: self
        )
    }()
    
    func updateMarketingEmailPreference(newValue: Bool, completion: @escaping (Error?) -> Void) {
        var user = self.user
        user.optedIntoMarketing = newValue
        let candidate = self.candidate
        let account = Account(user: user, candidate: candidate)
        service.updateAccount(account) { (result) in
            switch result {
            case .success(let account):
                user.optedIntoMarketing = account.user.optedIntoMarketing
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return TableSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRowsInSection(section)
    }
    
    private func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = TableSection(rawValue: section) else { return 0 }
        switch section {
        case .appNotifications: return isShowingOpenIOSSettings ? 1 : 0 // 2 : 1
        case .marketingEmails: return 1
        case .removeAccount: return 1
        }
    }
    
    override init(coordinator: AccountCoordinator, accountService: AccountServiceProtocol) {
        super.init(coordinator: coordinator, accountService: accountService)
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        checkNotificationStatus()
    }
    
    @objc private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch settings.authorizationStatus {
                case .notDetermined, .denied:
                    self.isPushNotificationsEnabled = false
                default:
                    self.isPushNotificationsEnabled = true
                }
                self.tableView?.reloadData()
            }
        }
    }
    
    private func getEnableNotificationsCell(_ table: UITableView) -> UITableViewCell {
        return table.dequeueReusableCell(withIdentifier: EnableNotificationsCell.reuseIdentifier) as? EnableNotificationsCell ??  UITableViewCell()
    }
    
    private func getNotificationControlsCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: NotificationControlsCell.reuseIdentifier) as? NotificationControlsCell else { return  UITableViewCell() }
        cell.configureWith(preferences: notificationPreferences)
        return cell
    }
    
    private func getMarketingEMailCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: MarketingEmailCell.reuseIdentifier) as? MarketingEmailCell else { return  UITableViewCell() }
        cell.configureWith(preferences: emailPreferences)
        return cell
    }
    
    private func getRemoveAccountCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: RemoveAccountCell.reuseIdentifier) as? RemoveAccountCell else { return  UITableViewCell() }
        cell.configureWith(enabled: isLoggedIn) { [weak self] in
            self?.removeAccountRequested()
        }
        return cell
    }
    
    private func removeAccountRequested() {
        viewController?.removeAccountRequested()
    }
    
    private func openIOSSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl)
        else { return }
        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
        })
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = TableSection(rawValue: section) else { return nil }
        switch sectionType {
        case .appNotifications:
            return  numberOfRowsInSection(section) == 0 ? "" : "App Notifications"
        case .marketingEmails:
            return "Marketing Emails"
        case .removeAccount:
            return "Remove Account"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .appNotifications:
            switch indexPath.row {
            case 0:
                if isPushNotificationsEnabled {
                    return getNotificationControlsCell(tableView)
                } else {
                    return getEnableNotificationsCell(tableView)
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
        case .appNotifications:
            if isShowingOpenIOSSettings {
                if indexPath.row == 0 {
                    openIOSSettings()
                }
            }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

