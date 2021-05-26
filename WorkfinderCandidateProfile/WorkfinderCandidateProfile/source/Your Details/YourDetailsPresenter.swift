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
            DetailCellPresenter(type: .firstname, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .lastname, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .dob, date: Date(), onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .postcode, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .picklist(.language), picklist: picklistFor(type: .language)),
            DetailCellPresenter(type: .phone, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .email, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .password),
            DetailCellPresenter(type: .smsPreference),
            
        ],
        [
            DetailCellPresenter(type: .postcode, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .picklist(.gender), picklist: picklistFor(type: .gender)),
            DetailCellPresenter(type: .picklist(.ethnicity), picklist: picklistFor(type: .ethnicity))
        ]
    ]
    
    func onDetailChanged(_ detail: DetailCellPresenter) {
        viewController?.onDetailsChanged()
    }
    
    var isUpdateEnabled: Bool {
        allCellPresenters.joined().reduce(true) { (result, presenter) -> Bool in
            return result && presenter.isValid
        }
    }
    
    lazy var picklists: [AccountPicklist] = {
        AccountPicklistType.allCases.map { AccountPicklist(type: $0, service: service) }
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
    
    func syncAccountToServer(completion: @escaping (Error?) -> Void) {
        let repo = UserRepository()
        guard repo.isCandidateLoggedIn else { return }
        let candidate = repo.loadCandidate()
        let user = repo.loadUser()
        let oldAccount = Account(user: user, candidate: candidate)
        let updatedAccount = updateAccount(account: oldAccount)
        service.updateAccount(updatedAccount) {(result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedAccount):
                    repo.saveUser(updatedAccount.user)
                    repo.saveCandidate(updatedAccount.candidate)
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }
    
    func updateAccount(account: Account) -> Account {
        var user = account.user
        var candidate = account.candidate
        allCellPresenters.forEach { (sectionPresenters) in
            sectionPresenters.forEach { (presenter) in
                switch presenter.type {
                case .firstname:
                    user.firstname = presenter.text ?? ""
                case .lastname:
                    user.lastname = presenter.text ?? ""
                case .email:
                    user.email = presenter.text
                case .password:
                    break
                case .phone:
                    candidate.phone = presenter.text
                case .smsPreference:
                    candidate.preferSMS = presenter.isOn
                case .dob:
                    candidate.dateOfBirth = presenter.date?.workfinderDateString
                case .postcode:
                    candidate.postcode = presenter.text
                case .picklist(let type):
                    let picklist = picklistFor(type: type)
                    switch type {
                    case .language:
                        candidate.languages = picklist.selectedItems.compactMap({ (item) -> String? in
                            item.name
                        })
                    case .gender:
                        candidate.gender = picklist.selectedItems.first?.id
                    case .ethnicity:
                        candidate.ethnicity = picklist.selectedItems.first?.id
                    }
                }
            }
        }
        return Account(user: user, candidate: candidate)
    }
    
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
        let presenter = allCellPresenters[indexPath.section][indexPath.row]
        switch presenter.type {
        case .firstname:
            presenter.text = user.firstname
        case .lastname:
            presenter.text = user.lastname
        case .email:
            presenter.text = user.email
        case .password:
            presenter.text = user.password
        case .phone:
            presenter.text = candidate.phone
        case .smsPreference:
            presenter.isOn = candidate.preferSMS ?? false
        case .dob:
            presenter.date = nil
            if let dob = candidate.dateOfBirth {
                let df = DateFormatter()
                df.timeStyle = .none
                df.dateStyle = .long
                presenter.date = Date.workfinderDateStringToDate(dob)
            }
        case .postcode:
            presenter.text = candidate.postcode
        case .picklist(let type):
            let picklist = picklistFor(type: type)
            if !picklist.isLocallySynchronised {
                switch picklist.type {
                case .language:
                    selectItemsFromIds(candidate.languages ?? [], for: picklist)
                case .gender:
                    selectItemsFromIds([candidate.gender ?? ""], for: picklist)
                case .ethnicity:
                    selectItemsFromIds([candidate.ethnicity ?? ""], for: picklist)
                }
            }
            picklist.isLocallySynchronised = true
        }
        return presenter
    }
    
    func selectItemsFromIds(_ ids: [String], for picklist: AccountPicklist) {
        picklist.deselectAll()
        ids.forEach { (id) in
            if id != "" {
                _ = picklist.selectItemHavingId(id)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let presenter = presenterForIndexPath(indexPath)
        switch presenter.type.dataType {
        case .picklist(let picklistType):
            coordinator?.showPicklist(picklistFor(type: picklistType)) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .password:
            coordinator?.showChangePassword()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let presenter = presenterForIndexPath(indexPath)
        if presenter.shouldSelectRow { viewController?.view.endEditing(false) }
        return presenter.shouldSelectRow
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
