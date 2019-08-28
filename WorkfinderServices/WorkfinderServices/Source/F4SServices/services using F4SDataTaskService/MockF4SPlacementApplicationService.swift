//
//  MockWEXPlacementService.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 03/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon


public class MockF4SPlacementApplicationService : F4SPlacementApplicationServiceProtocol {
    
    public var resultForCreate: F4SNetworkResult<WEXPlacementJson>?
    public var resultForPatch: F4SNetworkResult<WEXPlacementJson>?
    public var createCount: Int = 0
    public var patchCount: Int = 0
    
    public init(createResult: F4SNetworkResult<WEXPlacementJson>) {
        self.resultForCreate = createResult
    }
    
    public init(patchResult: F4SNetworkResult<WEXPlacementJson>) {
        self.resultForPatch = patchResult
    }
    
    public func apply(with json: WEXCreatePlacementJson, completion: @escaping (F4SNetworkResult<WEXPlacementJson>) -> Void) {
        createCount += 1
        completion(resultForCreate!)
    }
    
    public func update(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (F4SNetworkResult<WEXPlacementJson>) -> Void) {
        patchCount += 1
        completion(resultForPatch!)
    }
}
