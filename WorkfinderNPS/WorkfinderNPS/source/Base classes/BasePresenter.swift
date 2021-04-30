//
//  BasePresenter.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import Foundation


class BasePresenter {
    
    weak var coordinator: WorkfinderNPSCoordinator?
    var service: NPSServiceProtocol
    weak var viewController: BaseViewController?
    var npsModel: NPSModel
    
    var hostName: String? { npsModel.hostName }
    var projectName: String? { npsModel.projectName }
    var companyName: String? { npsModel.companyName }
    var score: Int? { npsModel.score }
    
    var category: QuestionCategory? { npsModel.category }
    
    func onViewDidLoad(vc: BaseViewController) {
        self.viewController = vc
    }
        
    init(coordinator: WorkfinderNPSCoordinator, service: NPSServiceProtocol, nps: NPSModel) {
        self.coordinator = coordinator
        self.service = service
        self.npsModel = nps
    }

}
