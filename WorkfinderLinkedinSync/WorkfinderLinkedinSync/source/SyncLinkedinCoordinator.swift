//
//  SyncLinkedinCoordinator.swift
//  WorkfinderLinkedinSync
//
//  Created by Keith on 14/06/2021.
//

import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderServices

public class SynchLinkedinCoordinator: CoreInjectionNavigationCoordinator {

    private var introController: IntroController?
    public var syncDidComplete: ((SynchLinkedinCoordinator) -> Void)?
    
    public override func start() {
        startIntro()
    }
    
    public func startIntro() {
        let name = UserRepository().loadUser().firstname ?? ""
        introController = IntroController(coordinator: self, name: name)
        introController?.present()
    }
    
    private func coordinatorDidFinish() {
        syncDidComplete?(self)
        parentCoordinator?.childCoordinatorDidFinish(self)
    }

}

protocol IntroCoordinator: AnyObject {
    var router: NavigationRoutingProtocol { get }
    func introChoseSkip()
    func introChoseSync()
}

extension SynchLinkedinCoordinator: IntroCoordinator {
    
    var router: NavigationRoutingProtocol { navigationRouter }
    
    func introChoseSkip() {
        coordinatorDidFinish()
    }
    
    func introChoseSync() {
        guard let workfinderHost = injected.networkConfig.host else { return }
        let oauthViewController = OAuthLinkedinViewController(host: workfinderHost, coordinator: self)
        navigationRouter.present(oauthViewController, animated: true, completion: nil)
    }
}

extension SynchLinkedinCoordinator: OAuthLinkedinCoordinator {
    func oauthLinkedinDidComplete(_ cancelled: Bool) {
        coordinatorDidFinish()
    }
}
