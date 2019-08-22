//
//  F4SPlacementService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SPlacementService : F4SPlacementServiceProtocol {
    
    var dataTask: F4SNetworkTask?
    var sessionManager: F4SNetworkSessionManagerProtocol
    var networkTaskFactory: F4SNetworkTaskFactoryProtocol
    
    public init(sessionManager: F4SNetworkSessionManagerProtocol = F4SNetworkSessionManager.shared) {
        self.networkTaskFactory = F4SNetworkTaskFactory()
        self.sessionManager = sessionManager
    }
    
    public func getPlacementOffer(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4STimelinePlacement>) -> ()) {
        let attempting = "Get placement"
        let verb = F4SHttpRequestVerb.get
        var url = URL(string: WorkfinderEndpoint.offerUrl)!
        url.appendPathComponent(uuid)
        let session = sessionManager.interactiveSession
        dataTask?.cancel()
        dataTask = networkTaskFactory.networkTask(verb: verb, url: url, dataToSend: nil, attempting: attempting, session: session) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                decoder.decode(data: data, intoType: F4STimelinePlacement.self, attempting: attempting, completion: completion)
            }
        }
        dataTask?.resume()
    }
    
    public func getAllPlacementsForUser(completion: @escaping (F4SNetworkResult<[F4STimelinePlacement]>) -> ()) {
        let attempting = "Get all placements"
        let verb = F4SHttpRequestVerb.get
        let url = URL(string: WorkfinderEndpoint.allPlacementsUrl)!
        let session = sessionManager.interactiveSession
        dataTask?.cancel()
        dataTask = networkTaskFactory.networkTask(verb: verb, url: url, dataToSend: nil, attempting: attempting, session: session) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                decoder.decode(data: data, intoType: [F4STimelinePlacement].self, attempting: attempting, completion: completion)
            }
        }
        dataTask?.resume()
    }

    public func ratePlacement(placementUuid: String, rating: Int, completion: @escaping (F4SNetworkResult<Bool>) -> ()) throws {
        throw F4SError.notImplementedYet("F4SPlacementService.ratePlacement")
    }
    
    public func confirmPlacement(placement: F4STimelinePlacement, voucherCode: String, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        let attempting = "Confirm placement with voucher"
        struct Confirm : Codable {
            var confirmed: Bool
            var voucher: String
        }
        let confirmJson = Confirm(confirmed: true, voucher: voucherCode)
        patchPlacement(placement.placementUuid!, json: confirmJson, attempting: attempting, completion: completion)
    }
    
    public func cancelPlacement(_ uuid: F4SUUID, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        let attempting = "Cancel placement"
        struct Cancel : Codable {
            var cancelled: Bool
        }
        let cancelJson = Cancel(cancelled: true)
        patchPlacement(uuid, json: cancelJson, attempting: attempting, completion: completion)
    }
    
    public func declinePlacement(_ uuid: F4SUUID, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        let attempting = "Decline placement"
        struct Decline : Codable {
            var declined: Bool
        }
        let declineJson = Decline(declined: true)
        patchPlacement(uuid, json: declineJson, attempting: attempting, completion: completion)
    }
    
    internal func patchPlacement<T:Encodable>(_ uuid: F4SUUID, json: T, attempting: String, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        do {
            let urlString = WorkfinderEndpoint.patchPlacementUrl + "/\(uuid)"
            let url = URL(string: urlString)!
            let session = sessionManager.interactiveSession
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(json)
            dataTask?.cancel()
            dataTask = networkTaskFactory.networkTask(verb: .patch, url: url, dataToSend: data, attempting: attempting, session: session) { result in
                switch result {
                case .error(let error):
                    completion(F4SNetworkResult.error(error))
                case .success(_):
                    completion(F4SNetworkResult.success(true))
                }
            }
            dataTask?.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(json).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
}
