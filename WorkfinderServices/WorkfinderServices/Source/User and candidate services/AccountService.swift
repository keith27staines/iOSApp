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
    func getCountriesPicklist(completion: @escaping (Result<[Country], Error>) -> Void)
    func getLanguagesPicklist(completion: @escaping (Result<[Language], Error>) -> Void)
    func getEducationLevelsPicklist(completion: @escaping (Result<[EducationLevel], Error>) -> Void)
    func getEthnicitiesPicklist(completion: @escaping (Result<[Ethnicity], Error>) -> Void)
    func getGendersPicklist(completion: @escaping (Result<[Gender], Error>) -> Void)
    func updateAccount(_ account: Account, completion: @escaping (Result<Account,Error>) -> Void)
    func deleteAccount(email: String, completion: @escaping (Result<DeleteAccountJson,Error>) -> Void)
    func requestPasswordReset(email: String, completion: @escaping (Result<[String:String],Error>) -> Void)
    func getLinkedInData(completion: @escaping (Result<LinkedinConnectionData?,Error>) -> Void)
    func getSkillsPicklist(completion: @escaping (Result<[Skill], Error>) -> Void)
    func getPersonalAttributesPicklist(completion: @escaping (Result<[PersonalAttribute], Error>) -> Void)

}

public protocol LinkedinDataServiceProtocol: AnyObject {
    func getLinkedInData(completion: @escaping (Result<LinkedinConnectionData?, Error>) -> Void)
}

public class SocialMediaService: WorkfinderService, LinkedinDataServiceProtocol {
    
    private enum Provider: String {
        case linkedin_oauth2
    }
    
    public func getLinkedInData(completion: @escaping (Result<LinkedinConnectionData?,Error>) -> Void) {
        getSocialConnections(provider: .linkedin_oauth2) { result in
            switch result {
            case .success(let connections):
                completion(.success(connections.first))               
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getSocialConnections(provider: Provider, completion: @escaping (Result<[LinkedinConnectionData],Error>) -> Void) {
        do {
            let queryItems = [URLQueryItem(name: "provider", value: provider.rawValue)]
            let request = try buildRequest(relativePath: "auth/accounts/social/connections/", queryItems: queryItems, verb: .get)
            performTask(with: request, verbose: true, completion: completion, attempting: "GET SocialConnections")
        } catch {
            completion(.failure(error))
        }
    }

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
    
    private lazy var _educationLevelsService: EducationLevelsService = EducationLevelsService(networkConfig: networkConfig)
    private lazy var _gendersService: GendersService = GendersService(networkConfig: networkConfig)
    private lazy var _countriesService: CountriesService = CountriesService(networkConfig: networkConfig)
    private lazy var _languagesService: LanguagesService = LanguagesService(networkConfig: networkConfig)
    private lazy var _ethnicitiesService: EthnicitiesService = EthnicitiesService(networkConfig: networkConfig)
    private lazy var _skillsService: SkillsService = SkillsService(networkConfig: networkConfig)
    private lazy var _personalAttributesService: PersonalAttributesService = PersonalAttributesService(networkConfig: networkConfig)
    private lazy var _linkedinDataService: SocialMediaService = SocialMediaService(networkConfig: networkConfig)
    
    public override init(networkConfig: NetworkConfig) {
        userService = FetchMeService(networkConfig: networkConfig)
        candidateService = FetchCandidateService(networkConfig: networkConfig)
        updateCandidateService = UpdateCandidateService(networkConfig: networkConfig)
        updateUserService = UpdateUserService(networkConfig: networkConfig)
        requestPasswordResetService = RequestPasswordResetService(networkConfig: networkConfig)
        super.init(networkConfig: networkConfig)
    }
    
    public func deleteAccount(email: String, completion: @escaping (Result<DeleteAccountJson, Error>) -> Void) {
        updateUserService.deleteAccount(email: email, completion: completion)
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
                var education_level: String
                var strongest_skills: [String]
                var attributes: [String]
            }
            
            let patch = CandidatePatch(
                phone: candidate.phone,
                postcode: candidate.postcode ?? "",
                date_of_birth: candidate.dateOfBirth,
                languages: candidate.languages ?? [],
                ethnicity: candidate.ethnicity ?? "",
                gender: candidate.gender ?? "",
                prefer_sms: candidate.preferSMS,
                education_level: candidate.educationLevel ?? "",
                strongest_skills: candidate.strongestSkills ?? [],
                attributes: candidate.personalAttributes ?? []
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
    
    public func getEducationLevelsPicklist(completion: @escaping (Result<[EducationLevel], Error>) -> Void) {
        _educationLevelsService.getEducationLevels(completion: completion)
    }
    
    public func getLanguagesPicklist(completion: @escaping (Result<[Language], Error>) -> Void) {
        _languagesService.getLanguages(completion: completion)
    }

    public func getCountriesPicklist(completion: @escaping (Result<[Country], Error>) -> Void) {
        _countriesService.getCountries(completion: completion)
    }

    public func getEthnicitiesPicklist(completion: @escaping (Result<[Ethnicity], Error>) -> Void) {
        _ethnicitiesService.getEthnicities(completion: completion)
    }
    
    public func getSkillsPicklist(completion: @escaping (Result<[Skill], Error>) -> Void) {
        _skillsService.getSkills(completion: completion)
    }
    
    public func getPersonalAttributesPicklist(completion: @escaping (Result<[PersonalAttribute], Error>) -> Void) {
        _personalAttributesService.getAttributes(completion: completion)
    }
    
    public func getGendersPicklist(completion: @escaping (Result<[Gender], Error>) -> Void) {
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
                let request = try buildRequest(relativePath: "education-requirements/", queryItems: nil, verb: .get)
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
                let request = try buildRequest(relativePath: "countries/", queryItems: nil, verb: .get)
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
    
    private class SkillsService: WorkfinderService {
        func getSkills(completion: @escaping (Result<[Skill], Error>) -> Void) {
            _getSkills { result in
                switch result {
                case .success(let serverlistJson):
                    completion(.success(serverlistJson.results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private func _getSkills(completion: @escaping (Result<ServerListJson<Skill>, Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "placement-skills/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private class PersonalAttributesService: WorkfinderService {
        func getAttributes(completion: @escaping (Result<[PersonalAttribute], Error>) -> Void) {
            _getAttributes { result in
                switch result {
                case .success(let serverlistJson):
                    completion(.success(serverlistJson.results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private func _getAttributes(completion: @escaping (Result<ServerListJson<PersonalAttribute>, Error>) -> Void) {
            do {
                let request = try buildRequest(relativePath: "placement-attributes/", queryItems: nil, verb: .get)
                performTask(with: request, verbose: true ,completion: completion, attempting: #function)
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension AccountService: LinkedinDataServiceProtocol {
    public func getLinkedInData(completion: @escaping (Result<LinkedinConnectionData?, Error>) -> Void) {
        _linkedinDataService.getLinkedInData(completion: completion)
    }
}
