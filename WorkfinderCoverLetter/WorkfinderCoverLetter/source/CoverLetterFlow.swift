
import WorkfinderCommon
import WorkfinderUI
import WorkfinderServices
import WorkfinderCoordinators

public class CoverLetterFlow: CoreInjectionNavigationCoordinator, UserMessageHandlingProtocol {
    
    public var messageHandler: UserMessageHandler? { return nil }
    weak var applyCoordinator: CoverLetterParentCoordinatorProtocol?
    weak var coverLetterViewController: CoverLetterViewController?
    weak var letterEditorViewController: LetterEditorViewController?
    weak var originViewController: UIViewController?
    var picklistsDidUpdate: ((PicklistsDictionary) -> Void)?
    let logic: CoverLetterLogic
    
    init(parent: CoverLetterParentCoordinatorProtocol?,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         logic: CoverLetterLogic) {
        self.originViewController = navigationRouter.navigationController.topViewController
        self.applyCoordinator = parent
        self.logic = logic
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    func onLetterEditorTapPrimaryButton()       {}
    func onLetterEditorDismiss()                {}
    func onCoverLetterTapPrimaryButton()        {}
    func onCoverLetterDismiss()                 {}
    func onCoverLetterTapEdit()                 {}
    func onLetterEditorDidUpdate()              {}
    func onCoverLetterTapField(name: String)    {}
    
    func finishWorkflow(cancelled: Bool) {
        logic.save()
        if cancelled {
            applyCoordinator?.coverLetterDidCancel()
        } else {
            applyCoordinator?.coverLetterCoordinatorDidComplete(
                coverLetterText: logic.letterDisplayString,
                picklistsDictionary: logic.allPicklistsDictionary
            )
        }
        
    }

    func showPicklist(_ picklist: PicklistProtocol) {
        switch picklist.type {
        case .skills,
             .strongestSkills,
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
    
    func calendarDidChangeRange(_ calendar: F4SCalendarCollectionViewController, firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        guard let firstDay = firstDay, let lastDay = lastDay else { return }
        
        let startDate = makeDate(year: firstDay.year, month: firstDay.monthOfYear, day: firstDay.dayOfMonth)
        let endDate = makeDate(year: lastDay.year, month: lastDay.monthOfYear, day: lastDay.dayOfMonth)
        
        let datePicklist = logic.allPicklistsDictionary[.availabilityPeriod]
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
    
    func picklistIsClosing(_ picklist: PicklistProtocol) {
        picklistDidClose()
    }
    
    func textEditorIsClosing(text: String) {
        picklistDidClose()
    }
    
    func picklistDidClose() {
        picklistsDidUpdate?(logic.allPicklistsDictionary)
        letterEditorViewController?.refresh()
    }
}

extension CoverLetterFlow: LetterEditorCoordinatorProtocol,
                           CoverletterCoordinatorProtocol,
                           PicklistCoordinatorProtocol,
                           F4SCalendarCollectionViewControllerDelegate,
                           TextEditorCoordinatorProtocol {
}
