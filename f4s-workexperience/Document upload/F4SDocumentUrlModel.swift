//
//  F4SDocumentUrlModel.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import Foundation
import UIKit

public struct F4SDocumentUrlDescriptor {
    public var id: Int
    public var name: String
    public var urlString : String
    public var includeInApplication: Bool = false
    public var isValidUrl: Bool {
        return URL(string: urlString) == nil ? false : true
    }
    public var url: URL? {
        return URL(string: urlString)
    }
}

public protocol F4SDocumentUrlModelDelegate {
    func documentUrlModel(_ model: F4SDocumentUrlModel, deleted: F4SDocumentUrlDescriptor)
}

public class F4SDocumentUrlModel {
    
    public var delegate: F4SDocumentUrlModelDelegate?
    
    public private (set) var urlDescriptors : [F4SDocumentUrlDescriptor]
    
    public init(urlStrings: [String]) {
        self.urlDescriptors = []
        for string in urlStrings {
            _ = createNewLink(string: string, includeInApplication: true)
        }
    }
    
    func setDescriptor(_ descriptor: F4SDocumentUrlDescriptor, at index: Int) {
        urlDescriptors[index] = descriptor
    }
    
    func deleteDescriptor(index: Int) {
        let removed = urlDescriptors[index]
        urlDescriptors.remove(at: index)
        delegate?.documentUrlModel(self, deleted: removed)
    }
    
    func createNewLink(string: String = "", includeInApplication: Bool) -> F4SDocumentUrlDescriptor {
        let index = urlDescriptors.count
        let newLink = F4SDocumentUrlDescriptor(id: index, name: String(index), urlString: string, includeInApplication: includeInApplication)
        urlDescriptors.append(newLink)
        return newLink
    }
}

extension F4SDocumentUrlModel {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(for section: Int) -> Int {
        return urlDescriptors.count
    }
}
