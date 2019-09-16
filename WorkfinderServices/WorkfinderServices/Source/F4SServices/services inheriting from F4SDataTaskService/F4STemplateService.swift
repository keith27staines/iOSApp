//
//  F4STemplateService.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4STemplateService:  F4SDataTaskService, F4STemplateServiceProtocol {
    
    public init(configuration: NetworkConfig) {
        let apiName = "cover-template"
        super.init(baseURLString: configuration.workfinderApiV2, apiName: apiName, configuration: configuration)
    }
    
    public func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        let attempting = "Get templates"
        beginGetRequest(attempting: attempting, completion: completion)
    }
}
