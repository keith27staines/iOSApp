//
//  DocumentsService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

public protocol F4SDocumentServiceProtocol {
    var apiName: String { get }
    var placementUuid: String { get }
    func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentUrlJson>) -> ())
}

public class F4SPlacementDocumentsService : F4SDataTaskService {
    public typealias SuccessType = [F4SDocumentUrl]
    
    override public var apiName: String {
        return "placement/\(self.placementUuid)/documents"
    }
    
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        super.init(baseURLString: Config.BASE_URL, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService : F4SDocumentServiceProtocol {
    public func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentUrlJson>) -> ()) {
        super.get(attempting: "Get supporting document urls for this placement", completion: completion)
    }
    
    public func putDocumentsForPlacement(documentDescriptors: F4SPutDocumentsUrlJson, completion: @escaping ((F4SNetworkResult<String>) -> Void )) {
        super.put(putObject: documentDescriptors, attempting: "Post supporting document urls for this placement", completion: completion)
    }
}

