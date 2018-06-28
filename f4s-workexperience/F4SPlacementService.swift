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
    func getAllPlacementsForUser(completion: @escaping (_ result: F4SNetworkResult<[F4STimeline]>) -> ())
    func ratePlacement(placementUuid: String, rating: Int, completion: @escaping ( F4SNetworkResult<Bool>) -> ())
}

public class F4SPlacementService : F4SPlacementServiceProtocol {
    
    public func getAllPlacementsForUser(completion: @escaping (F4SNetworkResult<[F4STimeline]>) -> ()) {
        
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
    
    public struct CoverLetterJson : Encodable {
        public var user_uuid: F4SUUID?
        public var company_uuid: F4SUUID?
        public var interests: [F4SUUID]?
        public var coverletter_choices: [CoverLetterBlankJson]?
    }
    
    public struct CoverLetterBlankJson : Encodable {
        public var name: String?
        public var result: F4SJSONValue?
    }
    
    public func updatePlacement(placement: F4SPlacement, template: F4STemplate, completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        let urlString = ApiConstants.updatePlacementUrl + "/\(placement.placementUuid!)"
        let url = URL(string: urlString)!
        let attempting = "Update placement"
        let session = F4SNetworkSessionManager.shared.interactiveSession
        
        var coverletterJson = CoverLetterJson()
        coverletterJson.user_uuid = placement.userUuid!
        coverletterJson.company_uuid = placement.companyUuid!
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
        coverletterJson.coverletter_choices = coverLetterObjects
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(coverletterJson)
            let urlRequest = F4SDataTaskService.urlRequest(verb: .post, url: url, dataToSend: data)
            let dataTask = F4SDataTaskService.dataTask(with: urlRequest, session: session, attempting: attempting) { result in
                completion(F4SNetworkResult.success(true))
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
            let data = try encoder.encode(createPlacement)
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
