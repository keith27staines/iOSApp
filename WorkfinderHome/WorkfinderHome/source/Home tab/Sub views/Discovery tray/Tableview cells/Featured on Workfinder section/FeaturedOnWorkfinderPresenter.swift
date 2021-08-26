//
//  FeaturedOnWorkfinderPresenter.swift
//  WorkfinderHome
//
//  Created by Keith on 25/08/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderCommon
import WorkfinderUI

class FeaturedOnWorkfinderPresenter {
    weak var messageHandler: HSUserMessageHandler?
    let rolesService: RolesServiceProtocol
    var roles: [RoleData] = []
    
    func load(completion: @escaping (Error?) -> Void) {
        rolesService.fetchTopRoles { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let roles):
                let maxRoles = min(6, roles.count)
                self.roles = ([RoleData](roles[0..<maxRoles])).map({ (roleData) -> RoleData in
                    var adaptedData = roleData
                    adaptedData.actionButtonText = roleData.actionButtonText
                    return adaptedData
                }).settingAppSource(.homeTabTopRolesList)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func roleTapped(roleData: RoleData) {
        NotificationCenter.default.post(name: .wfHomeScreenRoleTapped, object: roleData)
    }
    
    init(rolesService: RolesServiceProtocol, messageHandler: HSUserMessageHandler?) {
        self.rolesService = rolesService
        self.messageHandler = messageHandler
    }
}
