//
//  F4SCalendarService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderApplyUseCase
import WorkfinderNetworking

public protocol F4SPCalendarServiceProtocol {

}

public class F4SPCalendarService : F4SDataTaskService {
    
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPCalendarService : F4SPCalendarServiceProtocol {
    public func getAvailabilityForPlacement(completion: @escaping (F4SNetworkResult<[F4SAvailabilityPeriodJson]>) -> ()) {
        beginGetRequest(attempting: "Get availability periods for this placement", completion: completion)
    }
    
    public func patchAvailabilityForPlacement(availabilityPeriods: F4SAvailabilityPeriodsJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        beginSendRequest(verb: .patch, objectToSend: availabilityPeriods, attempting: "Patch availability periods for this placement", completion: completion)
    }
}
