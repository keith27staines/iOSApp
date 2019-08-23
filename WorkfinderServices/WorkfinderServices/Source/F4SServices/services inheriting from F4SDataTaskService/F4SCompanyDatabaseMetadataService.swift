//
//  F4SCompanyDatabaseMetadataService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 13/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SCompanyDatabaseMetaData : Codable {
    public var created: Date?
    public var urlString: String?
    public var errors: F4SJSONValue?
}

extension F4SCompanyDatabaseMetaData {
    private enum CodingKeys : String, CodingKey {
        case created
        case urlString = "url"
        case errors
    }
}

public protocol F4SCompanyDatabaseMetadataServiceProtocol {
    func getDatabaseMetadata(completion: @escaping (F4SNetworkResult<F4SCompanyDatabaseMetaData>) -> ())
}

public class F4SCompanyDatabaseMetadataService : F4SDataTaskService {
    
    public init() {
        let apiName = "company/dump/full"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
}

extension F4SCompanyDatabaseMetadataService : F4SCompanyDatabaseMetadataServiceProtocol {
    public func getDatabaseMetadata(completion: @escaping (F4SNetworkResult<F4SCompanyDatabaseMetaData>) -> ()) {
        beginGetRequest(attempting: "Get company database metadata", completion: completion)
    }
}

