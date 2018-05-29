//
//  DocumentsService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 21/02/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public protocol F4SDocumentServiceProtocol {
    var apiName: String { get }
    var placementUuid: String { get }
    func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentUrlJson>) -> ())
    func putDocumentsForPlacement(documentDescriptors: F4SPutDocumentsUrlJson, completion: @escaping ((F4SNetworkDataResult) -> Void ))
}

public class F4SPlacementDocumentsService : F4SDataTaskService {
    public typealias SuccessType = [F4SDocumentUrl]
    
    public let placementUuid: String
    
    public init(placementUuid: F4SUUID) {
        self.placementUuid = placementUuid
        let apiName = "placement/\(placementUuid)/documents"
        super.init(baseURLString: Config.BASE_URL, apiName: apiName, objectType: SuccessType.self)
    }
}

// MARK:- F4SDocumentServiceProtocol conformance
extension F4SPlacementDocumentsService : F4SDocumentServiceProtocol {
    public func getDocumentsForPlacement(completion: @escaping (F4SNetworkResult<F4SGetDocumentUrlJson>) -> ()) {
        super.get(attempting: "Get supporting document urls for this placement", completion: completion)
    }
    
    public func putDocumentsForPlacement(documentDescriptors: F4SPutDocumentsUrlJson, completion: @escaping ((F4SNetworkDataResult) -> Void )) {
        super.sendDataTask(verb: .put, objectToSend: documentDescriptors, attempting: "Put supporting document urls for this placement", completion: completion)
    }
}

