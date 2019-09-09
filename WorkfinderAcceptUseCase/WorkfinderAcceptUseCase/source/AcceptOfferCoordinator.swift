import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

let __bundle = Bundle(identifier: "com.f4s.WorkfinderAcceptUseCase")

public class AcceptOfferCoordinator : CoreInjectionNavigationCoordinator {
    
    let acceptContext: AcceptOfferContext
    let parent: CoreInjectionNavigationCoordinator
    var parentViewController: UIViewController?
    var firstViewController: UIViewController?
    let companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol
    
    public init(parent: CoreInjectionNavigationCoordinator,
         navigationRouter: NavigationRoutingProtocol,
         inject: CoreInjectionProtocol,
         acceptContext: AcceptOfferContext,
         companyCoordinatorFactory: CompanyCoordinatorFactoryProtocol) {
        self.parent = parent
        self.acceptContext = acceptContext
        self.companyCoordinatorFactory = companyCoordinatorFactory
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }

    public override func start() {
        let acceptStoryboard = UIStoryboard(name: "AcceptOffer", bundle: __bundle)
        let vc = acceptStoryboard.instantiateInitialViewController() as! AcceptOfferViewController
        vc.accept = acceptContext
        vc.coordinator = self
        navigationRouter.push(viewController: vc, animated: true)
        firstViewController = vc
        parentViewController = vc.parent
    }
    
    func showCompanyDetail(_ companyViewData: CompanyViewDataProtocol) {
        guard let companyCoordinator = companyCoordinatorFactory.makeCompanyCoordinator(parent: self, navigationRouter: navigationRouter, inject: injected, companyUuid: companyViewData.uuid) else { return }
        addChildCoordinator(companyCoordinator)
        companyCoordinator.start()
    }
    
    func didDecline() {
        didFinish()
    }
    
    func didCancel() {
        didFinish()
    }
    
    func didFinish() {
        guard let popTo = parentViewController ?? firstViewController else { return }
        navigationRouter.popToViewController(popTo, animated: true)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }
}

extension AcceptOfferCoordinator: CompanyCoordinatorParentProtocol {
    public func showMessages() {
        
    }
    
    public func showSearch() {
        
    }
}

extension AcceptOfferCoordinator {
    func createFinishingAlert(title: String,
                              message: String,
                              completion: @escaping () -> Void) -> UIAlertController {
        let style = UIAlertController.Style.alert
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            completion()
        }
        let controller = UIAlertController(title: title, message: message, preferredStyle: style)
        controller.addAction(okAction)
        return controller
    }
}

