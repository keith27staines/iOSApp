
import UIKit
import WorkfinderCommon
import WorkfinderCoordinators

public protocol CoverletterCoordinatorProtocol: class {
    func start()
    func onCoverLetterDidDismiss()
    func onDidCompleteCoverLetter()
    func onDidTapSelectOptions(referencedPicklists: PicklistsDictionary, completion: @escaping((PicklistsDictionary)->Void))
}

public class CoverLetterCoordinator: CoreInjectionNavigationCoordinator, CoverletterCoordinatorProtocol  {
    let templateProvider: TemplateProviderProtocol
    
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, candidateDateOfBirth: Date) {
        self.templateProvider = TemplateProvider(candidateDateOfBirth: candidateDateOfBirth)
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
    
    let allPicklistsDictionary: PicklistsDictionary = [
        .attributes: Picklist(type: .attributes, maximumPicks: 3),
        .roles: Picklist(type: .roles, maximumPicks: 1),
        .skills: Picklist(type: .skills, maximumPicks: 3),
        .universities: Picklist(type: .universities, maximumPicks: 1),
        .year: UniversityYearPicklist(),
        .availabilityPeriod: AvailabilityPeriodPicklist(),
        .freeTextBlock1: TextblockPicklist(type: .freeTextBlock1, placeholder: "Placeholder text 1"),
        .freeTextBlock2: TextblockPicklist(type: .freeTextBlock2, placeholder: "Placeholder text 2"),
        .freeTextBlock3: TextblockPicklist(type: .freeTextBlock3, placeholder: "Placeholder text 3")
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
        print("coordinator received: onDidCompleteCoverLetter")
    }
}

extension CoverLetterCoordinator: LetterEditorCoordinatorProtocol {
    func showPicklist(_ picklist: Picklist) {
        switch picklist.type {
        case .roles, .skills, .universities, .attributes, .year:
            let vc = PicklistViewController(coordinator: self, picklist: picklist)
            navigationRouter.push(viewController: vc, animated: true)
        case .availabilityPeriod:
            let storyboard = UIStoryboard(name: "F4SCalendar", bundle: __bundle)
            let vc = storyboard.instantiateInitialViewController() as! F4SCalendarContainerViewController
            vc.delegate = self
            navigationRouter.push(viewController: vc, animated: true)
            break
        case .freeTextBlock1, .freeTextBlock2, .freeTextBlock3:
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
        allPicklistsDictionary[.availabilityPeriod]?.items[0] = PicklistItemJson(uuid: "start", value: "Start")
        allPicklistsDictionary[.availabilityPeriod]?.items[1] = PicklistItemJson(uuid: "end", value: "End")
    }
}

extension CoverLetterCoordinator: PicklistCoordinatorProtocol {
    func picklistIsClosing(_ picklist: Picklist) {
        letterEditorViewController?.refresh()
    }
}

extension CoverLetterCoordinator: FreeTextEditorCoordinatorProtocol {
    func textEditorIsClosing() {
        letterEditorViewController?.refresh()
    }
}
