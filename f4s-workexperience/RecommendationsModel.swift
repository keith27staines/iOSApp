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
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        return recommendations.count
    }
    
    public func reload(completion: @escaping () -> ()) {
        RecommendationService.sharedInstance.getAllRecommendations { [weak self] (success, result) in
            guard let `self` = self else { return }
            self.recommendations = [Recommendation]()
            self.recommendations.append(Recommendation(companyName: "GigaCorp"))
            completion()
        }

    }
    
    public func recommendationForIndexPath(_ indexPath: IndexPath) -> Recommendation {
        return recommendations[indexPath.row]
    }
    
    public init() {}
}

public struct Recommendation : Decodable {
    
    public var companyName: String
    public var imageURL: URL?
    public var explanation: String? = nil
    
    public init(companyName: String) {
        self.companyName = companyName
        self.explanation = "Because you applied to MegaCorp"
    }
}
