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
    var cellsForIndexPath = [IndexPath:DetailCell]()
    
    enum TableSection: Int, CaseIterable {
        case yourInformation
        case additionalInformation
        
        var title: String {
            switch self {
            case .yourInformation: return "Profile Information"
            case .additionalInformation: return "Account Management"
            }
        }
        
        var subtitle: String {
            switch self {
            case .yourInformation: return "Manage information associated with your profile.\nAsterisk (*) indicates required"
            case .additionalInformation: return "Manage your account "
            }
        }
    }
    
    lazy var allCellPresenters: [[DetailCellPresenter]] = [
        [
            DetailCellPresenter(type: .firstname, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .lastname, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .dob, date: Date(), onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .phone, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .smsPreference, onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .picklist(.countryOfResidence), picklist: picklistFor(type: .countryOfResidence)),
            DetailCellPresenter(type: .postcode, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .picklist(.language), picklist: picklistFor(type: .language)),
            DetailCellPresenter(type: .picklist(.educationLevel), picklist: picklistFor(type: .educationLevel)),
            DetailCellPresenter(type: .picklist(.gender), picklist: picklistFor(type: .gender)),
            DetailCellPresenter(type: .picklist(.ethnicity), picklist: picklistFor(type: .ethnicity)),
            DetailCellPresenter(type: .picklist(.strongestSkills), picklist: picklistFor(type: .strongestSkills)),
            DetailCellPresenter(type: .picklist(.personalAttributes), picklist: picklistFor(type: .personalAttributes)),
        ],
        [
            DetailCellPresenter(type: .email, text: "", onValueChanged: onDetailChanged(_:)),
            DetailCellPresenter(type: .password),
            DetailCellPresenter(type: .removeAccount),
        ]
    ]
    
    func onDetailChanged(_ presenter: DetailCellPresenter) {
        informEditedAccountOfUpdatesFromUI(presenter: presenter)
        viewController?.onDetailsChanged()
    }
    
    var isUpdateEnabled: Bool {
        allCellPresenters.joined().reduce(isDirty) { (result, presenter) -> Bool in
            if !presenter.isValid {
                switch presenter.type {
                case .email:
                    print(presenter.isValid)
                default:
                    print(presenter.text ?? "nil text")
                }
                print("\(presenter.type) is invalid")
            }
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
    
    override func reloadPresenter(completion: @escaping (Error?) -> Void) {
        super.reloadPresenter { [weak self] error in
            guard let self = self else { return }
            if let error = error { completion(error) }
            self.allCellPresenters.flatMap { $0 }.forEach { presenter in
                self.updatePresenterData(presenter)
            }        
            completion(nil)
        }
    }
    
    func syncAccountToServer(completion: @escaping (Error?) -> Void) {
        let repo = UserRepository()
        guard repo.isCandidateLoggedIn else { return }
        service.updateAccount(editedAccount) {(result) in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let updatedAccount):
                    repo.saveUser(updatedAccount.user)
                    repo.saveCandidate(updatedAccount.candidate)
                    self?.editedAccount = updatedAccount
                    self?.tableView?.reloadData()
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }
    
    private func informEditedAccountOfUpdatesFromUI(presenter: DetailCellPresenter) {
        var user = editedAccount.user
        var candidate = editedAccount.candidate
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
            case .countryOfResidence:
                user.countryOfResidence = picklist.selectedItems.first?.id
            case .educationLevel:
                candidate.educationLevel = picklist.selectedItems.first?.id
            case .strongestSkills:
                candidate.strongestSkills = picklist.selectedItems.compactMap({ (item) -> String? in
                    item.id
                })
            case .personalAttributes:
                candidate.personalAttributes = picklist.selectedItems.compactMap({ (item) -> String? in
                    item.id
                })
            }
        case .removeAccount:
            break
        }
        editedAccount = Account(user: user, candidate: candidate)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return TableSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableSection(rawValue: section) else { return 0 }
        return allCellPresenters[section.rawValue].count
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
        return section.title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = TableSection(rawValue: section) else { return nil }
        let view = SectionHeaderView(section: section)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let presenter = presenterForIndexPath(indexPath)
        let cell: DetailCell
        if let existingCell = cellsForIndexPath[indexPath] {
            cell = existingCell
        } else {
            cell = DetailCell()
            cellsForIndexPath[indexPath] = cell
        }
        cell.configureWith(presenter: presenter)
        return cell
    }
    
    func updatePresenterData(_ presenter: DetailCellPresenter) {
        let user = editedAccount.user
        let candidate = editedAccount.candidate
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
                case .countryOfResidence:
                    selectItemsFromIds([user.countryOfResidence ?? ""], for: picklist)
                case .language:
                    selectItemsFromIds(candidate.languages ?? [], for: picklist)
                case .educationLevel:
                    selectItemsFromIds([candidate.educationLevel ?? ""], for: picklist)
                case .gender:
                    selectItemsFromIds([candidate.gender ?? ""], for: picklist)
                case .ethnicity:
                    selectItemsFromIds([candidate.ethnicity ?? ""], for: picklist)
                case .strongestSkills:
                    selectItemsFromIds(candidate.strongestSkills ?? [], for: picklist)
                case .personalAttributes:
                    selectItemsFromIds(candidate.personalAttributes ?? [], for: picklist)
                }
            }
            picklist.isLocallySynchronised = true
        case .removeAccount:
            break
        }
    }
    
    func presenterForIndexPath(_ indexPath: IndexPath) -> DetailCellPresenter {
        let presenter = allCellPresenters[indexPath.section][indexPath.row]
        updatePresenterData(presenter)
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
            coordinator?.showPicklist(picklistFor(type: picklistType)) { [weak self] in
                self?.informEditedAccountOfUpdatesFromUI(presenter: presenter)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .password:
            coordinator?.showChangePassword()
        case .action:
            viewController?.removeAccountRequested()
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
