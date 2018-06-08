//
//  F4SShortlistService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SShortlistJson : Decodable {
    public var companyUuid: F4SUUID
    public var errors: F4SServerErrors
}

public struct F4SServerErrors : Decodable {
    public var errors: JSONValue
}

public protocol F4SShortlistServiceProtocol {
    var apiName: String { get }
    func addCompany(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> ())
    func removeCompany(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ())
}

public class F4SShortlistService : F4SDataTaskService {
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: "favourite")
    }
}

// MARK:- F4SShortlistServiceProtocol conformance
extension F4SShortlistService : F4SShortlistServiceProtocol {
    
    public func addCompany(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> ()) {
        let params = ["company_uuid": companyUuid]
        let attempting = "Add company to shortist"
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
    
    public func removeCompany(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        super.beginGetRequest(attempting: "Remove company from shortlist", completion: completion)
    }
}

// MARK:- helper methods
extension F4SShortlistService {
    func decodeAddedCompanyData(_ data: Data?, attempting: String) -> F4SNetworkResult<F4SShortlistJson> {
        guard let data = data else {
            let error = F4SNetworkDataErrorType.noData.error(attempting: attempting)
            return F4SNetworkResult.error(error)
        }
        do {
            let shortlisted = try jsonDecoder.decode(F4SShortlistJson.self, from: data)
            return F4SNetworkResult.success(shortlisted)
        } catch {
            let error = F4SNetworkDataErrorType.undecodableData(data).error(attempting: attempting)
            return F4SNetworkResult.error(error)
        }
    }
}
