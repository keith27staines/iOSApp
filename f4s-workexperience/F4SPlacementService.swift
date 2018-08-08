//
//  F4SPlacementService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SPlacementServiceProtocol {
    func createPlacement(placement: F4SPlacement, completion: @escaping (_ result: F4SNetworkResult<F4SPlacementCreateResult>) -> ())
    func updatePlacement(placement: F4SPlacement, template: F4STemplate, completion: @escaping (F4SNetworkResult<Bool>) -> ())
    func getAllPlacementsForUser(completion: @escaping (_ result: F4SNetworkResult<[F4STimelinePlacement]>) -> ())
    func ratePlacement(placementUuid: String, rating: Int, completion: @escaping ( F4SNetworkResult<Bool>) -> ())
}

internal struct CoverLetterJson : Encodable {
    public var placementUuid: F4SUUID?
    public var templateUuid: F4SUUID?
    public var userUuid: F4SUUID?
    public var companyUuid: F4SUUID?
    public var interests: [F4SUUID]?
    public var choices: [CoverLetterBlankJson]?
}

extension CoverLetterJson {
    private enum CodingKeys : String, CodingKey {
        case placementUuid = "uuid"
        case templateUuid = "coverletter_uuid"
        case userUuid = "user_uuid"
        case companyUuid = "company_uuid"
        case interests
        case choices = "coverletter_choices"
    }
}

internal struct CoverLetterBlankJson : Encodable {
    public var name: String?
    public var result: F4SJSONValue?
}

public class F4SPlacementService : F4SPlacementServiceProtocol {
    
    private var dataTask: URLSessionDataTask?
    
    public func getPlacementOffer(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4STimelinePlacement>) -> ()) {
        let attempting = "Get placement"
        var url = URL(string: ApiConstants.offerUrl)!
        url.appendPathComponent(uuid)
        //url.appendPathComponent("offer")
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let urlRequest = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
        dataTask?.cancel()
        dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
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
        let url = URL(string: ApiConstants.allPlacementsUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let urlRequest = F4SDataTaskService.urlRequest(verb: .get, url: url, dataToSend: nil)
        dataTask?.cancel()
        dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
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
    
    public func ratePlacement(placementUuid: String, rating: Int, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        let attempting = "Rate placement"
        let url = URL(string: ApiConstants.ratingUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        var urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: nil)
        urlRequest.setValue(placementUuid, forHTTPHeaderField: "placement_uuid")
        urlRequest.setValue(String(rating), forHTTPHeaderField: "value")
        let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { (result) in
            switch result {
            case .error(let error):
                completion(F4SNetworkResult.error(error))
            case .success(_):
                completion(F4SNetworkResult.success(true))
            }
        }
        dataTask.resume()
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
            let urlString = ApiConstants.patchPlacementUrl + "/\(uuid)"
            let url = URL(string: urlString)!
            let session = F4SNetworkSessionManager.shared.interactiveSession
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(json)
            log.debug("updating placement with json \n\(String(data: data, encoding: .utf8)!)")
            let urlRequest = F4SDataTaskService.urlRequest(verb: .patch, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { result in
                switch result {
                case .error(let error):
                    completion(F4SNetworkResult.error(error))
                case .success(_):
                    completion(F4SNetworkResult.success(true))
                }
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(json).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
    
    public func updatePlacement(placement: F4SPlacement, template: F4STemplate, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        
        var coverletterJson = CoverLetterJson()
        coverletterJson.placementUuid = placement.placementUuid
        coverletterJson.templateUuid = template.uuid
        coverletterJson.userUuid = F4SUser.userUuidFromKeychain
        coverletterJson.companyUuid =  placement.companyUuid
        coverletterJson.interests = placement.interestList.map { (interest) -> F4SUUID in
            return interest.uuid
        }
        
        var coverLetterObjects: [CoverLetterBlankJson] = []
        for blank in template.blanks {
            let choices = blank.choices.map { (choice) -> F4SJSONValue in
                return F4SJSONValue(stringLiteral: choice.uuid)
            }
            var object = CoverLetterBlankJson()
            object.name = blank.name
            if blank.name == ChooseAttributes.EndDate.rawValue ||
               blank.name == ChooseAttributes.StartDate.rawValue ||
               blank.name == ChooseAttributes.JobRole.rawValue {
                object.result = choices.first
            } else {
                object.result = F4SJSONValue.array(choices)
            }
            coverLetterObjects.append(object)
        }
        coverletterJson.choices = coverLetterObjects
        let attempting = "Update placement"
        do {
            let urlString = ApiConstants.updatePlacementUrl + "/\(placement.placementUuid!)"
            let url = URL(string: urlString)!
            let session = F4SNetworkSessionManager.shared.interactiveSession
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(coverletterJson)
            log.debug("updating placement with json \n\(String(data: data, encoding: .utf8)!)")
            
            let urlRequest = F4SDataTaskService.urlRequest(verb: .put, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { result in
                switch result {
                case .error(let error):
                    completion(F4SNetworkResult.error(error))
                case .success(_):
                    completion(F4SNetworkResult.success(true))
                }
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(placement).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }
    }
    
    private struct PlacementJson : Encodable {
        var user_uuid: F4SUUID
        var company_uuid: F4SUUID
        var interests: [F4SUUID]
        var coverletter_choices: [String]?
    }
    
    public func createPlacement(placement: F4SPlacement, completion: @escaping (F4SNetworkResult<F4SPlacementCreateResult>) -> ()) {
        let attempting = "Create placement"
        let url = URL(string: ApiConstants.createPlacementUrl)!
        let session = F4SNetworkSessionManager.shared.interactiveSession
        let interests: [F4SUUID] = placement.interestList.map { (interest) -> F4SUUID in
            return interest.uuid
        }
        let userUuid = placement.userUuid!
        let companyUuid = placement.companyUuid!
        let createPlacement = PlacementJson(user_uuid: userUuid, company_uuid: companyUuid, interests: interests, coverletter_choices: nil)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(createPlacement)
            log.debug("creating placement with json \n\(String(data: data, encoding: .utf8)!)")
            let urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { [weak self] (result) in
                self?.handleCreateplacementTaskResult(attempting: attempting, dataResult: result, completion: completion)
                
            }
            dataTask.resume()
        } catch {
            let serializationError = F4SNetworkDataErrorType.serialization(placement).error(attempting: attempting)
            completion(F4SNetworkResult.error(serializationError))
        }

    }
    
    func handleCreateplacementTaskResult(attempting: String, dataResult: F4SNetworkDataResult, completion: @escaping (F4SNetworkResult<F4SPlacementCreateResult>) -> ()) {
        DispatchQueue.main.async {
            let decoder = JSONDecoder()
            decoder.decode(dataResult: dataResult, intoType: F4SPlacementCreateResult.self, attempting: attempting, completion: completion)
        }
    }
}
