//
//  F4SContentService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public enum F4SContentType: String, Codable {
    case about = "about-workfinder"
    case recommendations
    case faq
    case terms
    case voucher
    case consent
    case company
}

public struct F4SContentDescriptor : Codable {
    public var title: String
    public var slug: F4SContentType
    public var url: String?
    
    public init(title: String = "", slug: F4SContentType = .about, url: String? = "") {
        self.title = title
        self.slug = slug
        self.url = url
    }
}

public protocol F4SContentServiceProtocol {
    var apiName: String { get }
    func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ())
}

public class F4SContentService : F4SDataTaskService {
    public init() {
        super.init(baseURLString: Config.BASE_URL, apiName: "content")
    }
}

// MARK:- F4SContentServiceProtocol conformance
extension F4SContentService : F4SContentServiceProtocol {
    public func getContent(completion: @escaping (F4SNetworkResult<[F4SContentDescriptor]>) -> ()) {
        beginGetRequest(attempting: "Get content", completion: completion)
    }
}
