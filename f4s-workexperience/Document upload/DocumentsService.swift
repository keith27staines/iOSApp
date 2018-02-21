//
//  DocumentsService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
public class F4SDocumentsService : F4SDataTaskService {
    public static let apiName = "user/documents"
    public typealias SuccessType = [F4SDocumentUrl]
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: F4SRecommendationService.apiName, objectType: SuccessType.self)
    }
    
    public func fetch(completion: @escaping (F4SNetworkResult<SuccessType>) -> ()) {
        super.get(attempting: "Get recommendations", completion: completion)
    }
}
