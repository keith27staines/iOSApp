//
//  AccountPicklist.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 14/04/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

public protocol IdentifiedAndNamed {
    var id: String? { get set }
    var name: String? { get set }
    var category: String? { get set }
}

public struct EducationLevel: IdentifiedAndNamed, Codable {
    public var id: String?
    public var name: String?
    public var category: String?
    public init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
    private enum CodingKeys: String, CodingKey {
        case id = "value"
        case name = "label"
    }
}

public struct Country: IdentifiedAndNamed, Codable {
    public var id: String?
    public var name: String?
    public var category: String?
    public init(id: String?, name: String? = nil) {
        self.id = id
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "iso"
        case name
    }
}

public struct Language: IdentifiedAndNamed, Codable {
    public var id: String? {
        get { return name }
        set { }
    }
    public var name: String?
    public var category: String?
    public var nativeName: String?
    
    private enum CodingKeys: String, CodingKey {
        // case id = "iso_639_1" not needed because language uses the name as the id
        case name = "name_en"
        case nativeName = "name_native"
    }
    public init(name: String, nativeName: String) {
        self.id = name
        self.name = name
        self.nativeName = nativeName
        self.category = nil
    }
}

public struct Ethnicity: IdentifiedAndNamed, Codable {
    public var id: String?
    public var name: String?
    public var category: String?
    
    public init(id: String, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case category
    }
}

public struct Gender: IdentifiedAndNamed, Codable {
    public var id: String?
    public var name: String?
    public var category: String?
    public init(gender: String) {
        self.id = gender
        self.name = gender
        self.category = nil
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case category
    }

}
