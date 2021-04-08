//
//  AccountSectionViewModel.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 29/03/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

class AccountSectionViewModel {
    
    var title: String? = "Section Title"
    var fractionComplete: Double? = 0
    var candidateRepository: UserRepositoryProtocol = UserRepository()
    
    var candidate: Candidate {
        get { candidateRepository.loadCandidate() }
        set { candidateRepository.saveCandidate(newValue) }
    }
    
    var items = JsonDictionary()
    
    func update(completion: @escaping (Error?) -> Void) {
        items["item1"] = "hello"
        items["item2"] = 3
        items["item3"] = 4.5
      
    }
    
    
}

protocol CandidateUpdateServiceProtocol {
    func update(uuid: F4SUUID, items: JsonDictionary, completion: @escaping (Error?) -> Void)
}

class CandidateUpdateService: WorkfinderService, CandidateUpdateServiceProtocol {
    func update(uuid: F4SUUID, items: JsonDictionary, completion: @escaping (Error?) -> Void) {
        
    }
}

typealias JsonDictionary = [String: JsonPrimitive]

protocol JsonPrimitive {}

extension String: JsonPrimitive {}
extension Int: JsonPrimitive {}
extension Float: JsonPrimitive {}
extension Double: JsonPrimitive {}
extension Bool: JsonPrimitive {}
extension Array: JsonPrimitive where Element == JsonPrimitive {}
extension Dictionary: JsonPrimitive where Key == String, Value == JsonPrimitive {}
