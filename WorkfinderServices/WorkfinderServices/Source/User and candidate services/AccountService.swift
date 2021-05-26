//
//  AccountService.swift
//  WorkfinderServices
//
//  Created by Keith Staines on 09/04/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol AccountServiceProtocol {
    func getAccount(completion: @escaping (Result<Account,Error>) -> Void)
    func getCountriesPicklistcompletion(completion: @escaping (Result<[Country], Error>) -> Void)
    func getLanguagesPicklistcompletion(completion: @escaping (Result<[Language], Error>) -> Void)
    func getEducationLevelsPicklistcompletion(completion: @escaping (Result<[EducationLevel], Error>) -> Void)
    func getEthnicitiesPicklistcompletion(completion: @escaping (Result<[Ethnicity], Error>) -> Void)
    func getGendersPicklistcompletion(completion: @escaping (Result<[Gender], Error>) -> Void)
    func updateAccount(_ account: Account, completion: @escaping (Result<Account,Error>) -> Void)
    func deleteAccount(completion: @escaping (Result<DeleteAccountJson,Error>) -> Void)
    func requestPasswordReset(email: String, completion: @escaping (Result<[String:String],Error>) -> Void)
}

class RequestPasswordResetService: WorkfinderService {
    public func requestPasswordReset(email: String, completion: @escaping (Result<[String:String],Error>) -> Void) {
        let emailDict = ["email": email]
        do {
            let request = try buildRequest(relativePath: "auth/password/reset/", verb: .post, body: emailDict)
            performTask(with: request, completion: completion, attempting: "Request reset password")
        } catch {
            completion(.failure(error))
        }
    }
}

public class AccountService: WorkfinderService, AccountServiceProtocol {

    let userService: FetchMeService
    let candidateService: FetchCandidateService
    let updateCandidateService: UpdateCandidateServiceProtocol
    let updateUserService: UpdateUserService
    let requestPasswordResetService: RequestPasswordResetService
    
    public override init(networkConfig: NetworkConfig) {
        userService = FetchMeService(networkConfig: networkConfig)
        candidateService = FetchCandidateService(networkConfig: networkConfig)
        updateCandidateService = UpdateCandidateService(networkConfig: networkConfig)
        updateUserService = UpdateUserService(networkConfig: networkConfig)
        requestPasswordResetService = RequestPasswordResetService(networkConfig: networkConfig)
        super.init(networkConfig: networkConfig)
    }
    
    public func deleteAccount(completion: @escaping (Result<DeleteAccountJson, Error>) -> Void) {
        updateUserService.deleteAccount(completion: completion)
    }
    
    public func requestPasswordReset(email: String, completion: @escaping (Result<[String : String], Error>) -> Void) {
        requestPasswordResetService.requestPasswordReset(email: email, completion: completion)
    }
    
    public func updateAccount(_ account: Account, completion: @escaping (Result<Account, Error>) -> Void) {
        let user = account.user
        let candidate = account.candidate
        updateUserService.updateUser(user: user) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.updateCandidate(candidate, completion: { (result) in
                    switch result {
                    case .success(let candidate):
                        let account = Account(user: user, candidate: candidate)
                        completion(.success(account))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func updateCandidate(_ candidate: Candidate, completion: @escaping (Result<Candidate, Error>) -> Void) {
        do {
            let uuid = candidate.uuid ?? ""
            let relativePath = "candidates/\(uuid)/"
            
            struct CandidatePatch: Codable {
                var phone: String?
                var postcode: String?
                var date_of_birth: String?
                var languages: [String]
                var ethnicity: String?
                var gender: String?
                var prefer_sms: Bool?
            }
            let patch = CandidatePatch(
                phone: candidate.phone, //?? "",
                postcode: candidate.postcode ?? "",
                date_of_birth: candidate.dateOfBirth, //?? "",
                languages: candidate.languages ?? [],
                ethnicity: candidate.ethnicity ?? "",
                gender: candidate.gender ?? "",
                prefer_sms: candidate.preferSMS
            )
            
            let request = try buildRequest(relativePath: relativePath, verb: .patch, body: patch)
            performTask(with: request, verbose: true, completion: completion, attempting: #function)
        } catch {
            completion(Result<Candidate,Error>.failure(error))
        }
    }
    
    public func getAccount(completion: @escaping (Result<Account,Error>) -> Void) {
    
        getUser { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard let candidateUuid = user.candidateUuid else {
                    completion(.failure(WorkfinderError.init(errorType: .badParameters, attempting: "getAccount")))
                    return
                }
                self.getCandidate(uuid: candidateUuid) { (result) in
                    switch result {
                    case .success(let candidate):
                        completion(.success(Account(user: user, candidate: candidate)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getEducationLevelsPicklistcompletion(completion: @escaping (Result<[EducationLevel], Error>) -> Void) {
        
    }
    
    public func getLanguagesPicklistcompletion(completion: @escaping (Result<[Language], Error>) -> Void) {
        _languagesService.getLanguages(completion: completion)
    }

    public func getCountriesPicklistcompletion(completion: @escaping (Result<[Country], Error>) -> Void) {
        
    }

    public func getEthnicitiesPicklistcompletion(completion: @escaping (Result<[Ethnicity], Error>) -> Void) {
        _ethnicitiesService.getEthnicities(completion: completion)
    }
    
    public func getGendersPicklistcompletion(completion: @escaping (Result<[Gender], Error>) -> Void) {
        _gendersService.getGenders() { result in
            switch result {
            case .success(let genderStrings):
                let genders = genderStrings.map { (genderString) -> Gender in
                    Gender(gender: genderString)
                }
                completion(.success(genders))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private lazy var _educationLevelsService: EducationLevelsService = EducationLevelsService(networkConfig: networkConfig)
    private lazy var _gendersService: GendersService = GendersService(networkConfig: networkConfig)
    private lazy var _countriesService: CountriesService = CountriesService(networkConfig: networkConfig)
    private lazy var _languagesService: LanguagesService = LanguagesService(networkConfig: networkConfig)
    private lazy var _ethnicitiesService: EthnicitiesService = EthnicitiesService(networkConfig: networkConfig)
    
    private func getUser(completion: @escaping (Result<User,Error>) -> Void) {
        userService.fetch { (result) in
            completion(result)
        }
    }
    
    private func getCandidate(uuid: F4SUUID, completion: @escaping (Result<Candidate,Error>) -> Void) {
        candidateService.fetchCandidate(uuid: uuid) { (result) in
            completion(result)
        }
    }
    
    private class EducationLevelsService: WorkfinderService {
        func getEducationLevels(completion: @escaping (Result<[EducationLevel], Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "genders/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }

    private class GendersService: WorkfinderService {
        func getGenders(completion: @escaping (Result<[String], Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "genders/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private class CountriesService: WorkfinderService {
        func getCountries(completion: @escaping (Result<[Country], Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "genders/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }

    private class LanguagesService: WorkfinderService {
        func getLanguages(completion: @escaping (Result<[Language], Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "languages/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }

    private class EthnicitiesService: WorkfinderService {
        func getEthnicities(completion: @escaping (Result<[Ethnicity], Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "ethnicities/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }

}
