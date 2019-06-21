//
//  CompanyFavouritingService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SShortlistJson : Decodable {
    public var uuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var errors: F4SServerErrors?
    
    enum CodingKeys : String, CodingKey {
        case uuid
        case companyUuid = "company_uuid"
        case errors
    }
}

public struct F4SServerErrors : Decodable {
    public var errors: F4SJSONValue
}

public protocol CompanyFavouritingServiceProtocol {
    var apiName: String { get }
    func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> Void)
    func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> Void)
}

public class F4SCompanyFavouritingService : F4SDataTaskService, CompanyFavouritingServiceProtocol {

    public init() {
        super.init(baseURLString: NetworkConfig.BASE_URL2, apiName: "favourite")
    }
    
    public func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> ()) {
        let params = ["company_uuid": companyUuid]
        let attempting = "Create shortist item for company"
        relativeUrlString = nil
        super.beginSendRequest(verb: .post, objectToSend: params, attempting: attempting) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                completion(strongSelf.decodeAddedCompanyData(data, attempting: attempting))
            }
        }
    }
    
    public func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> ()) {
        let attempting = "Unfavourite"
        relativeUrlString = shortlistUuid
        super.beginDelete(attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                completion(F4SNetworkResult.success(shortlistUuid))
            }
        }
    }
}

// MARK:- helper methods
extension F4SCompanyFavouritingService {
    func decodeAddedCompanyData(_ data: Data?, attempting: String) -> F4SNetworkResult<F4SShortlistJson> {
        guard let data = data else {
            let error = F4SNetworkDataErrorType.noData.error(attempting: attempting)
            return F4SNetworkResult.error(error)
        }
        do {
            let shortlisted = try jsonDecoder.decode(F4SShortlistJson.self, from: data)
            return F4SNetworkResult.success(shortlisted)
        } catch {
            let error = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
            return F4SNetworkResult.error(error)
        }
    }
}
