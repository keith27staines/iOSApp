//
//  F4SVoucherService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SVoucherValidationError : Codable {
    public var status: String?
}

public struct F4SVoucherValidation : Codable {
    public var status: String?
    public var errors: F4SVoucherValidationError?
}

public protocol F4SVoucherVerificationServiceProtocol {
    var apiName: String { get }
    func verify(completion: @escaping (F4SNetworkResult<F4SVoucherValidation>) -> ())
    func cancel()
}

public class F4SVoucherVerificationService : F4SDataTaskService {
    public let placementUuid: F4SUUID
    public let voucherCode: F4SUUID
    
    public init(placementUuid: F4SUUID, voucherCode: String) {
        self.placementUuid = placementUuid
        self.voucherCode = voucherCode
        let api = "voucher/\(voucherCode)"
        super.init(baseURLString: NetworkConfig.BASE_URL2, apiName: api)
    }
}

// MARK:- F4SVoucherVerificationServiceProtocol conformance
extension F4SVoucherVerificationService : F4SVoucherVerificationServiceProtocol {
    
    public func verify(completion: @escaping (F4SNetworkResult<F4SVoucherValidation>) -> ()) {
        let params = ["placement_uuid" : placementUuid]
        let attempting = "Validate voucher code"
        beginSendRequest(verb: .put, objectToSend: params, attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult<F4SVoucherValidation>.error(error))
            case .success(let data):
                guard let data = data else {
                    let noDataError = F4SNetworkDataErrorType.noData.error(attempting: attempting, logError: true)
                    completion(F4SNetworkResult.error(noDataError))
                    return
                }
                let decoder = self.jsonDecoder
                do {
                    let voucherValidation = try decoder.decode(F4SVoucherValidation.self, from: data)
                    completion(F4SNetworkResult.success(voucherValidation))
                } catch {
                    let error = F4SNetworkDataErrorType.deserialization(data).error(attempting: attempting)
                    completion(F4SNetworkResult.error(error))
                }
            }
        }
    }
}
