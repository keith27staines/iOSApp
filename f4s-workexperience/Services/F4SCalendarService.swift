//
//  F4SCalendarService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SPCalendarServiceProtocol {

}

public class F4SPCalendarService : F4SDataTaskService {
    public typealias SuccessType = [F4SDocumentUrl]
    
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)"
        super.init(baseURLString: Config.BASE_URL2, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPCalendarService : F4SPCalendarServiceProtocol {
    public func getAvailabilityForPlacement(completion: @escaping (F4SNetworkResult<[F4SAvailabilityPeriodJson]>) -> ()) {
        super.get(attempting: "Get availability periods for this placement", completion: completion)
    }
    
    public func patchAvailabilityForPlacement(availabilityPeriods: F4SAvailabilityPeriodsJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        send(verb: .patch, object: availabilityPeriods, attempting: "Patch availability periods for this placement", completion: completion)
    }
}
