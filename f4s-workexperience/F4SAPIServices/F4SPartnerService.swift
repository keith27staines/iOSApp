//
//  PartnerService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 31/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SPartnerServiceProtocol {
    var apiName: String { get }
    func getPartners(completion: @escaping (F4SNetworkResult<[F4SPartner]>) -> ())
}

public class F4SPartnerService : F4SDataTaskService {
    public init() {
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: "partner")
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPartnerService : F4SPartnerServiceProtocol {
    public func getPartners(completion: @escaping (F4SNetworkResult<[F4SPartner]>) -> ()) {
        beginGetRequest(attempting: "Get partners", completion: completion)
    }
}
