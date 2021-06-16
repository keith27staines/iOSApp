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
    
    func startIntro() {
        let name = UserRepository().loadUser().firstname ?? ""
        introController = IntroController(coordinator: self, name: name)
        introController?.present()
    }
    
    private func coordinatorDidFinish() {
        parentCoordinator?.childCoordinatorDidFinish(self)
        
    }

}

protocol IntroCoordinator: AnyObject {
    var router: NavigationRoutingProtocol { get }
    func introChoseSkip()
    func introChoseManual()
    func introChoseAuto()
}

extension SynchLinkedinCoordinator: IntroCoordinator {
    
    var router: NavigationRoutingProtocol { navigationRouter }
    
    func introChoseSkip() {
        coordinatorDidFinish()
    }
    
    func introChoseManual() {
        
    }
    
    func introChoseAuto() {
        guard let workfinderHost = injected.networkConfig.host else { return }
        let oauthViewController = OAuthLinkedinViewController(host: workfinderHost, coordinator: self)
        navigationRouter.present(oauthViewController, animated: true, completion: nil)
    }
}

protocol PersonalInfoCoordinator: AnyObject {
    func personalInfoDidComplete()
}

extension SynchLinkedinCoordinator: PersonalInfoCoordinator {
    func personalInfoDidComplete() {
        
    }
}


protocol EducationInformationCoordinator: AnyObject {
    func educationInformationDidComplete()
}

extension SynchLinkedinCoordinator: EducationInformationCoordinator {
    func educationInformationDidComplete() {
    
    }
}

protocol ExperienceCoordinator: AnyObject {
    func experienceDidComplete()
}

extension SynchLinkedinCoordinator: ExperienceCoordinator {
    func experienceDidComplete() {
        self.syncDidComplete?(self)
    }
}

extension SynchLinkedinCoordinator: OAuthLinkedinCoordinator {
    func oauthLinkedinDidComlete(_ cancelled: Bool) {
        switch cancelled {
        case true:
            break
        case false:
            break
        }
    }
    
}
