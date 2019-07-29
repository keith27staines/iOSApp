//
//  MockWEXPlacementService.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 03/04/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon


public class MockWEXPlacementService : WEXPlacementServiceProtocol {
    
    public var resultForCreate: WEXResult<WEXPlacementJson, WEXError>?
    public var resultForPatch: WEXResult<WEXPlacementJson, WEXError>?
    public var createCount: Int = 0
    public var patchCount: Int = 0
    
    public init(createResult: WEXResult<WEXPlacementJson, WEXError>) {
        self.resultForCreate = createResult
    }
    
    public init(patchResult: WEXResult<WEXPlacementJson, WEXError>) {
        self.resultForPatch = patchResult
    }
    
    public func createPlacement(with json: WEXCreatePlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        createCount += 1
        completion(resultForCreate!)
    }
    
    public func patchPlacement(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        patchCount += 1
        completion(resultForPatch!)
    }
}
