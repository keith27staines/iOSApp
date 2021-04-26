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

class NewWindowManager {
    
    let originalWindow: UIWindow?
    
    private lazy var rootViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.navigationController?.navigationBar.isHidden = true
        return vc
    }()
    
    func loadWindow() {
        newWindow?.makeKeyAndVisible()
    }
    
    func unloadWindow() {
        navigationController.popViewController(animated: true)
        originalWindow?.makeKeyAndVisible()
        newWindow?.isHidden = true
        newWindow = nil
    }
    
    private lazy var newWindow: UIWindow? = {
        let window = UIWindow()
        window.rootViewController = navigationController
        window.backgroundColor = UIColor.white
        window.windowLevel = .statusBar
        return window
    }()
    
    public lazy var navigationController: UINavigationController = {
        let nvc = UINavigationController(rootViewController: rootViewController)
        return nvc
    }()
    
    init(originalWindow: UIWindow?) {
        self.originalWindow = originalWindow
    }
}



public class WorkfinderNPSCoordinator: CoreInjectionNavigationCoordinator {
    
    var score: Int?
    var npsUuid: F4SUUID
    var nps: NPSModel?

    lazy var newWindowManager: NewWindowManager = {
        return NewWindowManager(originalWindow: UIApplication.shared.windows.first)
    }()
    
    private lazy var newNav: NavigationRoutingProtocol = {
        let nav = newWindowManager.navigationController
        return NavigationRouter(navigationController: nav)
    }()
    
    var firstVC: BaseViewController? {
        didSet {
            firstVC?.onCancelNPS = finishedNPS
        }
    }
 
    public override func start() {
        showChoices()
    }
    
    func showChoices() {
        let presenter = ChooseNPSPresenter(coordinator: self, service: self)
        let vc = ChooseNPSViewController(coordinator: self, presenter: presenter, onComplete: showSubmit)
        displayViewController(vc)
    }
        
    func showSubmit() {
        let presenter = SubmitPresenter(coordinator: self, service: self)
        let vc = SubmitViewController(coordinator: self, presenter: presenter, onComplete: showThankyou)
        displayViewController(vc)
    }
    
    func showThankyou() {
        let presenter = ThankyouPresenter(coordinator: self, service: self)
        let vc = ThankyouViewController(coordinator: self, presenter: presenter, onComplete: finishedNPS)
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

    
    private func displayViewController(_ vc: BaseViewController) {
        let nvc = newWindowManager.navigationController
        if firstVC == nil {
            vc.isFirst = true
            newWindowManager.loadWindow()
            firstVC = vc
        }
        nvc.pushViewController(vc, animated: true)
    }
    
    func finishedNPS() {
        newWindowManager.unloadWindow()
    }
    
    func backToStart() {
        guard let firstVC = firstVC else { return }
        let nvc = newWindowManager.navigationController
        nvc.popToViewController(firstVC, animated: true)
    }
}

extension WorkfinderNPSCoordinator: NPSServiceProtocol {
    
    public func fetchNPS(uuid: String, completion: (Result<NPSModel, Error>) -> Void) {
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
    
    public func patchNPS(uuid: String, nps: NPSModel, completion: (Result<NPSModel, Error>) -> Void) {
        service.patchNPS(uuid: uuid, nps: nps, completion: completion)
    }
}
