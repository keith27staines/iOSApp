//
//  NPSCoordinator.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderCoordinators
import WorkfinderUI

public class WorkfinderNPSCoordinator: CoreInjectionNavigationCoordinator {
    
    var score: Int?
    var npsUuid: F4SUUID
    var nps: NPS?
    
    var firstVC: BaseViewController? {
        didSet {
            firstVC?.onCancelNPS = finishedNPS
        }
    }
 
    public override func start() {
        if let _ = score {
            showFeedback()
        } else {
            showChoices()
        }
    }
    
    func showChoices() {
        let presenter = ChooseNPSPresenter(coordinator: self, service: self)
        let vc = ChooseNPSViewController(coordinator: self, presenter: presenter, onComplete: showFeedback)
        displayViewController(vc)
    }
        
    func showFeedback() {
        let presenter = FeedbackPresenter(coordinator: self, service: self)
        let vc = FeedbackViewController(coordinator: self, presenter: presenter, onComplete: showOtherFeedback)
        displayViewController(vc)
    }
    
    func showOtherFeedback() {
        let presenter = OtherFeedbackPresenter(coordinator: self, service: self)
        let vc = OtherFeedbackViewController(coordinator: self, presenter: presenter, onComplete: finishedNPS)
        displayViewController(vc)
    }
                
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, npsUuid: F4SUUID, score: Int? ) {
        self.npsUuid = npsUuid
        self.score = score
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    private lazy var service: NPSServiceProtocol = {
        NPSService(networkConfig: injected.networkConfig)
    }()
    
    private var newNav: NavigationRoutingProtocol?
    
    private func displayViewController(_ vc: BaseViewController) {
//        if firstVC == nil {
//            firstVC = vc
//            let nvc = UINavigationController(rootViewController: vc)
//            newNav = NavigationRouter(navigationController: nvc)
//            navigationRouter.present(nvc, animated: true, completion: nil)
//        } else {
            navigationRouter.push(viewController: vc, animated: true)
//        }
    }
    
    private func finishedNPS() {
        parentCoordinator?.childCoordinatorDidFinish(self)
//        navigationRouter.dismiss(animated: true, completion: nil)
        navigationRouter.pop(animated: true)
    }
}

extension WorkfinderNPSCoordinator: NPSServiceProtocol {
    
    public func fetchNPS(uuid: String, completion: (Result<NPS, Error>) -> Void) {
        guard let nps = nps else {
            service.fetchNPS(uuid: npsUuid) { result in
                switch result {
                case .success(var nps):
                    nps.score = nps.score ?? score
                    completion(.success(nps))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        completion(.success(nps))
    }
    
    public func patchNPS(uuid: String, nps: NPS, completion: (Result<NPS, Error>) -> Void) {
        service.patchNPS(uuid: uuid, nps: nps, completion: completion)
    }
}
