//
//  WEXPlacementService.swift
//  WorkfinderNetworking
//
//  Created by Keith Dev on 15/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class WEXPlacementServiceFactory :  WEXPlacementServiceFactoryProtocol {
    public init() {}
    public func makePlacementService() -> WEXPlacementServiceProtocol {
        return WEXPlacementService()
    }
}

public class WEXPlacementService {
    typealias CreateCompletionHandler = ((WEXResult<WEXCreatePlacementJson, WEXError>) -> Void)
    public typealias WEXCreatePlacementResult = WEXResult<WEXPlacementJson, WEXError>
    public let placementApi: String
    var createPlacementTask: WEXDataTask?
    var patchPlacementTask: WEXDataTask?
    
    public init() {
        placementApi = NetworkConfig.workfinderApiV2  + "/placement"
    }
}

extension WEXPlacementService : WEXPlacementServiceProtocol {
    
    public func createPlacement(
        with json: WEXCreatePlacementJson,
        completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        let attempting = "Create placement"
        createPlacementTask?.cancel()
        let encoder = JSONEncoder()
        let payload = try! encoder.encode(json)
        createPlacementTask = WEXDataTask( urlString: placementApi, verb: WEXHTTPRequestVerb.post(payload)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let data = data else {
                        let error = WEXErrorsFactory.networkNoDataReturnedError(attempting: attempting)
                        let result = WEXResult<WEXPlacementJson, WEXError>.failure(error)
                        completion(result)
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let placementJson = try decoder.decode(WEXPlacementJson.self, from: data)
                        let result = WEXResult<WEXPlacementJson, WEXError>.success(placementJson)
                        completion(result)
                    } catch {
                        
                    }
                    
                case .failure(let error):
                    let result = WEXResult<WEXPlacementJson, WEXError>.failure(error)
                    completion(result)
                }
            }
        }
        createPlacementTask?.start()
    }
    
    public func patchPlacement(uuid: F4SUUID, with json: WEXPlacementJson, completion: @escaping (WEXResult<WEXPlacementJson, WEXError>) -> Void) {
        let attempting = "Update placement"
        patchPlacementTask?.cancel()
        let encoder = JSONEncoder()
        let payload = try! encoder.encode(json)
        let patchApi = placementApi + "/\(uuid)"
        patchPlacementTask = WEXDataTask( urlString: patchApi, verb: WEXHTTPRequestVerb.patch(payload)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let data = data else {
                        let error = WEXErrorsFactory.networkNoDataReturnedError(attempting: attempting)
                        let result = WEXResult<WEXPlacementJson, WEXError>.failure(error)
                        completion(result)
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let placementJson = try decoder.decode(WEXPlacementJson.self, from: data)
                        let result = WEXResult<WEXPlacementJson, WEXError>.success(placementJson)
                        completion(result)
                    } catch {
                        
                    }
                    
                case .failure(let error):
                    let result = WEXResult<WEXPlacementJson, WEXError>.failure(error)
                    completion(result)
                }
            }
        }
        patchPlacementTask?.start()
    }
}
