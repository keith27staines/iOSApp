//
//  DocumentUploadModel.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

class F4SDCDocumentUpload {
    var type: F4SUploadableDocumentType
    var name: String?
    var data: Data?
    var localUrlString: String? = nil
    var remoteUrlString: String? = nil
    var viewableUrlString: String? {
        return remoteUrlString ?? localUrlString
    }
    
    var viewableUrl: URL? {
        guard let viewableUrlString = viewableUrlString else { return nil }
        return URL(string: viewableUrlString)
    }
    
    func clearAllDetailsExceptType() {
        localUrlString = nil
        remoteUrlString = nil
        name = nil
        data = nil
    }
    
    public init(type: F4SUploadableDocumentType, name: String? = nil, urlString: String? = nil, data: Data? = nil) {
        self.type = type
        self.name = name
        self.localUrlString = urlString
        self.data = data
    }
    
    var isReadyForUpload: Bool {
        if let realData = data, realData.count > 0 { return true }
        if let urlString = remoteUrlString, let _ = URL(string: urlString) {
            return true
        }
        return false
    }
    
    var defaultName: String {
        return "My \(type)"
    }
    

}
