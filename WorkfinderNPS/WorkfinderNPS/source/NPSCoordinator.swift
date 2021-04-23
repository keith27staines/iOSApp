//
//  NPSCoordinator.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

public class WorkfinderNPSCoordinator: CoreInjectionNavigationCoordinator {
 
    public override func start() {
        if let _ = score {
            showFeedback()
        } else {
            showChoices()
        }
    }
    
    func showChoices() {
        let presenter = ChooseNPSPresenter(coordinator: self, service: self)
        let vc = ChooseNPSViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showFeedback() {
        let presenter = FeedbackPresenter(coordinator: self, service: self)
        let vc = FeedbackViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func showOtherFeedback() {
        let presenter = OtherFeedbackPresenter(coordinator: self, service: self)
        let vc = OtherFeedbackViewController(coordinator: self, presenter: presenter)
        navigationRouter.push(viewController: vc, animated: true)
    }
    
    func finishedNPS() {
        
    }
    
    func cancelNPS() {
        
    }
    
    var score: Int?
    var npsUuid: F4SUUID
    var nps: NPS?
    
    public init(parent: Coordinating?, navigationRouter: NavigationRoutingProtocol, inject: CoreInjectionProtocol, npsUuid: F4SUUID, score: Int? ) {
        self.npsUuid = npsUuid
        self.score = score
        super.init(parent: parent, navigationRouter: navigationRouter, inject: inject)
    }
    
    private lazy var service: NPSServiceProtocol = {
        NPSService(networkConfig: injected.networkConfig)
    }()
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
