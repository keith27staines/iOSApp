//
//  RecommendationsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 03/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public class RecommendationsModel {
    
    public var numberOfSections: Int { return 1 }
    private var recommendations: [Recommendation] = [Recommendation]()
    
    public var recommendationsExist: Bool {
        return (numberOfRowsInSection(0) > 0) ? true : false
    }
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        return recommendations.count
    }
    
    lazy var recommedationService: F4SRecommendationService = {
        return F4SRecommendationService()
    }()
    
    public func reload(completion: @escaping () -> ()) {
        recommedationService.fetch { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(var recommendations):
                recommendations = recommendations.sorted() { return $0.index < $1.index }
                DispatchQueue.main.async {
                    self.recommendations = recommendations
                    completion()
                }
            case .error(let error):
                DispatchQueue.main.async {
                    print("error refreshing recommendations \n\(error)")
                    completion()
                }
            }
        }
    }
    
    public func recommendationForIndexPath(_ indexPath: IndexPath) -> Recommendation {
        return recommendations[indexPath.row]
    }
    
    public init() {}
}

public struct Recommendation : Codable {
    /// Required sort index
    public let index: Int
    /// the company uuid
    public let uuid: F4SUUID!
    
    public init(companyUUID: F4SUUID, sortIndex: Int) {
        self.index = sortIndex
        self.uuid = companyUUID
    }

    lazy var company: Company? = {
        return DatabaseOperations.sharedInstance.companyWithUUID(uuid)
    }()
}
