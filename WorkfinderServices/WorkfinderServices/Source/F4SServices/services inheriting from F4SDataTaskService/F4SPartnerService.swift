//
//  PartnerService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 31/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import WorkfinderCommon
import WorkfinderNetworking

public class F4SPartnerService : F4SDataTaskService, F4SPartnerServiceProtocol {
    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApiV2, apiName: "partner", configuration: configuration)
    }

    public func getPartners(completion: @escaping (F4SNetworkResult<[F4SPartner]>) -> ()) {
        beginGetRequest(attempting: "Get partners", completion: completion)
    }
}
