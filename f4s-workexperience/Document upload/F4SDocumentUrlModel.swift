//
//  F4SDocumentUrlModel.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import Foundation
import UIKit

public struct F4SDocumentUrl : Codable {
    
    /// sort index
    public let index: Int
    /// url uuid
    public let uuid: F4SUUID!
    
    /// the url of the document
    public let urlString: String
    
    /// Initializes a new instance
    /// - parameter uuid: The uuid of the url
    /// - parameter sortIndex: The index used to sort this url in an array of urls
    /// - parameter urlString: The absolute string representation of the url
    public init(uuid: F4SUUID, sortIndex: Int, urlString: String) {
        self.index = sortIndex
        self.uuid = uuid
        self.urlString = urlString
    }
}

public struct F4SDocumentUrlDescriptor {
    public var id: Int
    public var name: String
    public var urlString : String
    public var includeInApplication: Bool = false
    public var isExpanded: Bool = false
    public var isValidUrl: Bool {
        guard let url = self.url else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    public var url: URL? {
        return URL(string: urlString)
    }
}

public protocol F4SDocumentUrlModelDelegate {
    func documentUrlModel(_ model: F4SDocumentUrlModel, deleted: F4SDocumentUrlDescriptor)
    func documentUrlModel(_ model: F4SDocumentUrlModel, updated: F4SDocumentUrlDescriptor)
    func documentUrlModel(_ model: F4SDocumentUrlModel, created: F4SDocumentUrlDescriptor)
}

public class F4SDocumentUrlModel {
    
    public let maxUrls : Int = 3
    private var delegate: F4SDocumentUrlModelDelegate?
    
    public var expandedIndexPath: IndexPath? {
        for i in 0..<urlDescriptors.count {
            if urlDescriptors[i].isExpanded {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
    
    private var urlDescriptors : [F4SDocumentUrlDescriptor]
    
    public func urlDescriptor(_ indexPath: IndexPath) -> F4SDocumentUrlDescriptor {
        return urlDescriptors[indexPath.row]
    }
    
    public func contains(url: URL) -> Bool {
        for descriptor in urlDescriptors {
            if descriptor.url?.absoluteString == url.absoluteString {
                return true
            }
        }
        return false
    }
    
    public init(urlStrings: [String], delegate: F4SDocumentUrlModelDelegate) {
        self.delegate = delegate
        self.urlDescriptors = []
        for string in urlStrings {
            _ = createDescriptor(string: string, includeInApplication: true)
        }
    }
    
    func canAddLink() -> Bool {
        if urlDescriptors.count >= maxUrls { return false }
        for descriptor in urlDescriptors {
            if !descriptor.isValidUrl {
                return false
            }
        }
        return true
    }
    
    func setDescriptor(_ descriptor: F4SDocumentUrlDescriptor, at indexPath: IndexPath) {
        urlDescriptors[indexPath.row] = descriptor
        delegate?.documentUrlModel(self, updated: descriptor)
    }
    
    func expandDescriptor(at indexPath: IndexPath) {
        collapseAllRows()
        var descriptor = urlDescriptors[indexPath.row]
        descriptor.isExpanded = true
        urlDescriptors[indexPath.row] = descriptor
    }
    
    public func collapseAllRows() {
        for (index,descriptor) in urlDescriptors.enumerated() {
            var descr = descriptor
            descr.isExpanded = false
            urlDescriptors[index] = descr
        }
    }
    
    func deleteDescriptor(indexPath: IndexPath) {
        let removed = urlDescriptors[indexPath.row]
        urlDescriptors.remove(at: indexPath.row)
        delegate?.documentUrlModel(self, deleted: removed)
    }
    
    func createDescriptor(string: String = "", includeInApplication: Bool) -> F4SDocumentUrlDescriptor? {
        if !canAddLink() { return nil }
        let index = urlDescriptors.count
        let newDescriptor = F4SDocumentUrlDescriptor(id: index, name: String(index), urlString: string, includeInApplication: includeInApplication, isExpanded: false)
        urlDescriptors.insert(newDescriptor, at: 0)
        delegate?.documentUrlModel(self, created: newDescriptor)
        return newDescriptor
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
