//
//  F4SShortlistService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SShortlistJson : Decodable {
    public var uuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var errors: F4SServerErrors?
}

public struct F4SServerErrors : Decodable {
    public var errors: JSONValue
}

public protocol F4SCreateShortlistItemServiceProtocol {
    var apiName: String { get }
    func createShortlistItemForCompany(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> ())
    
}

public class F4SCreateShortlistItemService : F4SDataTaskService, F4SCreateShortlistItemServiceProtocol {
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: "favourite")
    }
 
    public func createShortlistItemForCompany(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> ()) {
        let params = ["company_uuid": companyUuid]
        let attempting = "Create shortist item for company"
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
}

// MARK:- helper methods
extension F4SCreateShortlistItemService {
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
