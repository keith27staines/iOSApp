//
//  YourDetailsPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import WorkfinderCommon
import WorkfinderServices

class YourDetailsPresenter: BaseAccountPresenter {
    
    var viewController: YourDetailsViewController?
    
    enum TableSection: Int, CaseIterable {
        case yourInformation
        case additionalInformation
        
        var title: String {
            switch self {
            case .yourInformation: return "Your Notifications"
            case .additionalInformation: return "Additional information"
            }
        }
    }
    
    lazy var allCellPresenters: [[DetailCellPresenter]] = [
        [
            DetailCellPresenter(type: .fullname, text: "Full name"),
            DetailCellPresenter(type: .email, text: "Email@Address.com"),
            DetailCellPresenter(type: .password),
            DetailCellPresenter(type: .phone, text: "07757262284"),
            DetailCellPresenter(type: .dob, date: Date())
        ],
        [
            DetailCellPresenter(type: .postcode, text: "HU89AG"),
            DetailCellPresenter(type: .picklist(.language), picklist: picklistFor(type: .language)),
            DetailCellPresenter(type: .picklist(.gender), picklist: picklistFor(type: .gender)),
            DetailCellPresenter(type: .picklist(.ethnicity), picklist: picklistFor(type: .ethnicity))
        ]
    ]
    
    lazy var picklists: [AccountPicklist] = {
        AccountPicklistType.allCases.map { AccountPicklist(type: $0) }
    }()
    
    func picklistFor(type: AccountPicklistType) -> AccountPicklist {
        picklists[type.rawValue]
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
            allowMarketingEmails: true
        )
    }()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return TableSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableSection(rawValue: section) else { return 0 }
        switch section {
        case .yourInformation: return 5
        case .additionalInformation: return 4
        }
    }
    
    override init(coordinator: AccountCoordinator, accountService: AccountServiceProtocol) {
        super.init(coordinator: coordinator, accountService: accountService)
    
    }
            
    private func getNotificationControlsCell(_ table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: NotificationControlsCell.reuseIdentifier) as? NotificationControlsCell else { return  UITableViewCell() }
        cell.configureWith(preferences: notificationPreferences)
        return cell
    }

        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = TableSection(rawValue: section) else { return nil }
        switch section {
        case .yourInformation:
            return "Your information"
        case .additionalInformation:
            return "Additional information"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let presenter = presenterForIndexPath(indexPath)
        let cell = DetailCell()
        cell.configureWith(presenter: presenter)
        return cell
    }
    
    func presenterForIndexPath(_ indexPath: IndexPath) -> DetailCellPresenter {
        allCellPresenters[indexPath.section][indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let presenter = presenterForIndexPath(indexPath)
        switch presenter.type.dataType {
        case .picklist(let picklistType):
            coordinator?.showPicklist(picklistFor(type: picklistType))
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let section = TableSection(rawValue: indexPath.section) else { return false }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
