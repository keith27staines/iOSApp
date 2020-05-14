
import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderCoordinators

public protocol CoverletterCoordinatorProtocol: class {
    func start()
    func onCoverLetterDidDismiss()
    func onDidCompleteCoverLetter()
    func onDidTapSelectOptions(referencedPicklists: PicklistsDictionary, completion: @escaping((PicklistsDictionary)->Void))
}

public protocol PicklistsStoreProtocol {
    var allPicklistsDictionary: PicklistsDictionary { get }
    func load() -> PicklistsDictionary
    func save()
}
public class PicklistsStore: PicklistsStoreProtocol {
    let networkConfig: NetworkConfig
    let localStore:LocalStorageProtocol
    let otherItem = PicklistItemJson(uuid: PicklistItemJson.otherItemUuid, value: "Other")
    
    public init(networkConfig: NetworkConfig, localStore:LocalStorageProtocol) {
        self.networkConfig = networkConfig
        self.localStore = localStore
    }
    
    public var allPicklistsDictionary: PicklistsDictionary = [:]
    
    public func load() -> PicklistsDictionary {
        let picklists = buildPicklists()
        let selectedItems = loadSelectedItems()
        assignSelectedValues(picklists: picklists, selectedItems: selectedItems)
        allPicklistsDictionary = picklists
        return picklists
    }
    
    func loadSelectedItems() -> [PicklistType: [PicklistItemJson]] {
        typealias ItemsDictionary = [PicklistType: [PicklistItemJson]]
        guard
            let data = localStore.value(key: LocalStore.Key.picklistsSelectedValuesData) as? Data,
            let items = try? JSONDecoder().decode(ItemsDictionary.self, from: data)
            else {
            return [:]
        }
        return items
    }
    
    public func save() {
        var items = [PicklistType:[PicklistItemJson]]()
        allPicklistsDictionary.forEach { (key, picklist) in
            items[key] = picklist.selectedItems
        }
        let data = try? JSONEncoder().encode(items)
        localStore.setValue(data, for: LocalStore.Key.picklistsSelectedValuesData)
    }
    
    func assignSelectedValues(picklists: PicklistsDictionary,
                              selectedItems: [PicklistType: [PicklistItemJson]]) {
        picklists.forEach { (key, picklist) in
            picklist.deselectAll()
            picklist.selectItems(selectedItems[key] ?? [])
        }
    }
    
    /*
     Final Fields are:
     (FE type, number to choose)
     *         Year (pick list & 'other', 1)
     *         Subject (pick list & 'other', 1)
     *         Institution (Typeahead & 'other', 1)
     *         Placement Type (pick list, 1)
     *         Project (pick list & 'other', 1)
     *         Motivation (free text)
     *         Availability (date picker)
     *         Duration (pick list, 1)
     *         Experience (free text)
     *         Attributes (pick list, 1-3)
     *         Skills (pick list, 1-3)
     */
    func buildPicklists() -> PicklistsDictionary {
        return [
            .year: Picklist(type: .year, otherItem: otherItem, maximumPicks: 1, networkConfig: networkConfig),
            .subject: Picklist(type: .subject, otherItem: otherItem, maximumPicks: 1, networkConfig: networkConfig),
            .institutions: TextSearchPicklist(type: .institutions, otherItem: otherItem, networkConfig: networkConfig),
            .placementType: Picklist(type: .placementType, otherItem: nil, maximumPicks: 1, networkConfig: networkConfig),
            .project: Picklist(type: .project, otherItem: otherItem, maximumPicks: 1, networkConfig: networkConfig),
            .motivation: TextblockPicklist(type: .motivation, networkConfig: networkConfig),
            .availabilityPeriod: AvailabilityPeriodPicklist(networkConfig: networkConfig),
            .duration: Picklist(type: .duration, otherItem: nil, maximumPicks: 1, networkConfig: networkConfig),
            .experience: TextblockPicklist(type: .experience, networkConfig: networkConfig),
            .attributes: Picklist(type: .attributes, otherItem: nil, maximumPicks: 3, networkConfig: networkConfig),
            .skills: Picklist(type: .skills, otherItem: nil, maximumPicks: 3, networkConfig: networkConfig),
        ]
    }
}

public class CoverLetterCoordinator: CoreInjectionNavigationCoordinator, CoverletterCoordinatorProtocol  {
    let templateProvider: TemplateProviderProtocol
    weak var applyCoordinator: ApplyCoordinator?
    weak var coverLetterViewController: CoverLetterViewController?
    weak var letterEditorViewController: LetterEditorViewProtocol?
    var networkConfig: NetworkConfig { return injected.networkConfig}
    var picklistsDidUpdate: ((PicklistsDictionary) -> Void)?
    
    public init(parent: ApplyCoordinator?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, candidateDateOfBirth: Date) {
        self.applyCoordinator = parent
        self.templateProvider = TemplateProvider(
            networkConfig: inject.networkConfig,
            candidateDateOfBirth: candidateDateOfBirth)
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    lazy var presenter: CoverLetterViewPresenterProtocol = {
        let presenter = CoverLetterViewPresenter(
            coordinator: self,
            templateProvider: self.templateProvider,
            picklistsStore: self.picklistsStore)
        return presenter
    }()
    
    lazy var picklistsStore: PicklistsStoreProtocol = {
        let localStore = LocalStore()
        return PicklistsStore(
            networkConfig: self.injected.networkConfig,
            localStore: localStore)
    }()
    
    override public func start() {
        super.start()
        let viewController = CoverLetterViewController(presenter: presenter)
        self.coverLetterViewController = viewController
        navigationRouter.push(viewController: viewController, animated: true)
    }
    
    public func onDidTapSelectOptions(referencedPicklists: PicklistsDictionary, completion: @escaping ((PicklistsDictionary) -> Void)) {
        picklistsDidUpdate = completion
        let presenter = LetterEditorPresenter(coordinator: self, picklists: referencedPicklists)
        let letterEditorViewController = LetterEditorViewController(presenter: presenter)
        self.letterEditorViewController = letterEditorViewController
        coverLetterViewController?.navigationController?.pushViewController(letterEditorViewController, animated: true)
    }
    
    public func onCoverLetterDidDismiss() {
        picklistsStore.save()
        print("coordinator received: onDidCancelCoverLetter")
    }

    public func onDidCompleteCoverLetter() {
        picklistsStore.save()
        self.applyCoordinator?.coverLetterCoordinatorDidComplete(presenter: presenter)
        self.parentCoordinator?.childCoordinatorDidFinish(self)
    }
    
    func picklistDidClose() {
        picklistsDidUpdate?(picklistsStore.allPicklistsDictionary)
        letterEditorViewController?.refresh()
    }
}

extension CoverLetterCoordinator: LetterEditorCoordinatorProtocol {
    func showPicklist(_ picklist: PicklistProtocol) {
        switch picklist.type {
        case .skills,
             .attributes,
             .year,
             .subject,
             .placementType,
             .project,
             .duration:
            let vc = PicklistViewController(coordinator: self, picklist: picklist)
            navigationRouter.push(viewController: vc, animated: true)
            
        case .institutions:
            guard let picklist = picklist as? TextSearchPicklistProtocol else { return }
            let vc = SearchlistViewController<String>(coordinator: self, picklist: picklist)
            navigationRouter.push(viewController: vc, animated: true)
            
        case .availabilityPeriod:
            let storyboard = UIStoryboard(name: "F4SCalendar", bundle: __bundle)
            guard let vc = storyboard.instantiateInitialViewController() as? F4SCalendarContainerViewController else { return }
            vc.delegate = self
            if picklist.selectedItems.count > 0 {
                if let startDateString = picklist.selectedItems[0].value {
                    vc.firstDate = Date.workfinderDateStringToDate(startDateString)
                }
            }
            if picklist.selectedItems.count > 1 {
                if let endDateString = picklist.selectedItems[1].value {
                    vc.lastDate = Date.workfinderDateStringToDate(endDateString)
                }
            }
            navigationRouter.push(viewController: vc, animated: true)
            
        case .motivation, .experience:
            let vc = FreeTextEditorViewController(coordinator: self, freeTextPicker: picklist as! TextblockPicklist)
            navigationRouter.push(viewController: vc, animated: true)
        }
    }
    
    func letterEditorDidComplete(view: LetterEditorViewProtocol) {
        //picklistsDidUpdate?(picklistsStore.allPicklistsDictionary)
    }
}

extension CoverLetterCoordinator: F4SCalendarCollectionViewControllerDelegate {
    func calendarDidChangeRange(_ calendar: F4SCalendarCollectionViewController, firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        guard let firstDay = firstDay, let lastDay = lastDay else { return }
        
        let startDate = makeDate(year: firstDay.year, month: firstDay.monthOfYear, day: firstDay.dayOfMonth)
        let endDate = makeDate(year: lastDay.year, month: lastDay.monthOfYear, day: lastDay.dayOfMonth)
        
        let datePicklist = picklistsStore.allPicklistsDictionary[.availabilityPeriod]
        var startDateItem = PicklistItemJson(uuid: "first", value: startDate.workfinderDateString)
        var endDateItem = PicklistItemJson(uuid: "last", value: endDate.workfinderDateString)
        startDateItem.isDateString = true
        endDateItem.isDateString = true
        datePicklist?.deselectAll()
        datePicklist?.selectItems([
            startDateItem,
            endDateItem
        ])
        picklistDidClose()
    }
    
    func makeDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)!
    }
}

extension CoverLetterCoordinator: PicklistCoordinatorProtocol {
    
    func picklistIsClosing(_ picklist: PicklistProtocol) {
        picklistDidClose()
    }
}

extension CoverLetterCoordinator: TextEditorCoordinatorProtocol {
    func textEditorIsClosing(text: String) {
        picklistDidClose()
    }
}
