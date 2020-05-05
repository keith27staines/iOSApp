
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

public class CoverLetterCoordinator: CoreInjectionNavigationCoordinator, CoverletterCoordinatorProtocol  {
    let templateProvider: TemplateProviderProtocol
    weak var applyCoordinator: ApplyCoordinator?
    
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
            allPicklistsDictionary: self.allPicklistsDictionary)
        return presenter
    }()
    
    weak var coverLetterViewController: CoverLetterViewController?
    weak var letterEditorViewController: LetterEditorViewProtocol?
    
    override public func start() {
        super.start()
        let viewController = CoverLetterViewController(presenter: presenter)
        self.coverLetterViewController = viewController
        navigationRouter.push(viewController: viewController, animated: true)
    }
    
    var networkConfig: NetworkConfig { return injected.networkConfig}
    let otherItem = PicklistItemJson(uuid: "other", value: "Other")
    lazy var allPicklistsDictionary: PicklistsDictionary = [
        .attributes: Picklist(type: .attributes, otherItem: nil, maximumPicks: 3, networkConfig: networkConfig),
        .roles: Picklist(type: .roles, otherItem: nil, maximumPicks: 1, networkConfig: networkConfig),
        .skills: Picklist(type: .skills, otherItem: nil, maximumPicks: 3, networkConfig: networkConfig),
        .universities: TextSearchPicklist(type: .universities, otherItem: self.otherItem, networkConfig: networkConfig),
        .year: UniversityYearPicklist(otherItem: otherItem, networkConfig: networkConfig),
        .availabilityPeriod: AvailabilityPeriodPicklist(networkConfig: networkConfig),
        .motivation: TextblockPicklist(
            type: .motivation,
            placeholder: "My motivation for seeking work experience is...", networkConfig: networkConfig),
        .reason: TextblockPicklist(
            type: .reason,
            placeholder: "I’m particularly interested in working with you or your company because...", networkConfig: networkConfig),
        .experience: TextblockPicklist(
            type: .experience,
            placeholder: "My relevant experience is... or why you should consider me", networkConfig: networkConfig)
    ]
    
    var picklistsDidUpdate: ((PicklistsDictionary) -> Void)?
    
    public func onDidTapSelectOptions(referencedPicklists: PicklistsDictionary, completion: @escaping ((PicklistsDictionary) -> Void)) {
        picklistsDidUpdate = completion
        let presenter = LetterEditorPresenter(coordinator: self, picklists: referencedPicklists)
        let letterEditorViewController = LetterEditorViewController(presenter: presenter)
        self.letterEditorViewController = letterEditorViewController
        coverLetterViewController?.navigationController?.pushViewController(letterEditorViewController, animated: true)
    }
    
    public func onCoverLetterDidDismiss() {
        print("coordinator received: onDidCancelCoverLetter")
    }

    public func onDidCompleteCoverLetter() {
        self.applyCoordinator?.coverLetterCoordinatorDidComplete(presenter: presenter)
        self.parentCoordinator?.childCoordinatorDidFinish(self)
    }
}

extension CoverLetterCoordinator: LetterEditorCoordinatorProtocol {
    func showPicklist(_ picklist: PicklistProtocol) {
        switch picklist.type {
        case .roles, .skills, .attributes, .year:
            let vc = PicklistViewController(coordinator: self, picklist: picklist)
            navigationRouter.push(viewController: vc, animated: true)
            
        case .universities:
            guard let picklist = picklist as? TextSearchPicklistProtocol else {
                return
            }
            let vc = SearchlistViewController<String>(coordinator: self, picklist: picklist)
            navigationRouter.push(viewController: vc, animated: true)
            
        case .availabilityPeriod:
            let storyboard = UIStoryboard(name: "F4SCalendar", bundle: __bundle)
            let vc = storyboard.instantiateInitialViewController() as! F4SCalendarContainerViewController
            vc.delegate = self
            navigationRouter.push(viewController: vc, animated: true)
            
        case .motivation, .reason, .experience:
            let vc = FreeTextEditorViewController(coordinator: self, freeTextPicker: picklist as! TextblockPicklist)
            navigationRouter.push(viewController: vc, animated: true)
        }
    }
    
    func letterEditorDidComplete(view: LetterEditorViewProtocol) {
        picklistsDidUpdate?(allPicklistsDictionary)
    }
}

extension CoverLetterCoordinator: F4SCalendarCollectionViewControllerDelegate {
    func calendarDidChangeRange(_ calendar: F4SCalendarCollectionViewController, firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        guard let firstDay = firstDay, let lastDay = lastDay else { return }
        
        let startDate = makeDate(year: firstDay.year, month: firstDay.monthOfYear, day: firstDay.dayOfMonth)
        let endDate = makeDate(year: lastDay.year, month: lastDay.monthOfYear, day: lastDay.dayOfMonth)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        allPicklistsDictionary[.availabilityPeriod]?.selectedItems = [
            PicklistItemJson(uuid: "first", value: dateFormatter.string(from: startDate)),
            PicklistItemJson(uuid: "last", value: dateFormatter.string(from: endDate))
        ]
        letterEditorViewController?.refresh()
    }
    
    func makeDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)!
    }
}

extension CoverLetterCoordinator: PicklistCoordinatorProtocol {
    func picklistIsClosing(_ picklist: PicklistProtocol) {
        letterEditorViewController?.refresh()
    }
}

extension CoverLetterCoordinator: FreeTextEditorCoordinatorProtocol {
    func textEditorIsClosing() {
        letterEditorViewController?.refresh()
    }
}
