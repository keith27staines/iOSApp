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

/*
 https://develop.workfinder.com/reviews/cc59a4f4-0c2b-47e1-9c98-77b80c3f400f/?access_token=7TomNR3W1OowciVeO2IZgpjMJph330oppq0OLylCDZM
 */

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

    var nps: NPSModel

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
        let presenter = ChooseNPSPresenter(coordinator: self, service: self, nps: nps)
        let vc = ChooseNPSViewController(coordinator: self, presenter: presenter, onComplete: showSubmit)
        displayViewController(vc)
    }
        
    func showSubmit() {
        let presenter = SubmitPresenter(coordinator: self, service: self, nps: nps)
        presenter.npsModel = nps
        let vc = SubmitViewController(coordinator: self, presenter: presenter, onComplete: showThankyou)
        displayViewController(vc)
    }
    
    func showThankyou() {
        let presenter = ThankyouPresenter(coordinator: self, service: self, nps: nps)
        let vc = ThankyouViewController(coordinator: self, presenter: presenter, onComplete: finishedNPS)
        displayViewController(vc)
    }
                
    public init(
        parent: Coordinating?,
        navigationRouter: NavigationRoutingProtocol,
        inject: CoreInjectionProtocol,
        npsUuid: F4SUUID,
        accessToken: String?,
        score: Int?
    ) {
        self.nps = NPSModel(accessToken: accessToken, uuid: npsUuid, score: score)
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
    
    func fetchReasons(completion: @escaping (Result<[ReasonJson], Error>) -> Void) {
        service.fetchReasons(completion: completion)
    }
    
    func fetchNPS(uuid: String, completion: @escaping (Result<GetReviewJson, Error>) -> Void) {
        service.fetchNPS(uuid: uuid, completion: completion)
    }
    
    func patchNPS(nps: NPSModel, completion: @escaping (Result<NPSModel, Error>) -> Void) {
        service.patchNPS(nps: nps, completion: completion)
    }
}
