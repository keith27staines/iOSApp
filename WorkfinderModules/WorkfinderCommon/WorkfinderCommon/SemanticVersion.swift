//
//  SemanticVersion.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 12/02/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public struct SemanticVersion: Hashable, Comparable {
    
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        guard lhs.components[.major] == rhs.components[.major] else {
            return lhs.components[.major] ?? "0" < rhs.components[.major] ?? "0"
        }
        guard lhs.components[.minor] == rhs.components[.minor] else {
            return lhs.components[.minor] ?? "0" < rhs.components[.minor] ?? "0"
        }
        return lhs.components[.patch] ?? "0" < rhs.components[.patch] ?? "0"
    }
    
    public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        lhs ~= rhs &&
        (lhs.components[.patch] ?? "0") == (rhs.components[.patch] ?? "0")
    }
    
    public static func ~= (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        (lhs.components[.major] ?? "0") == (rhs.components[.major] ?? "0") &&
        (lhs.components[.minor] ?? "0") == (rhs.components[.minor] ?? "0")
    }
    
    public var major: String { return components[.major] ?? "0" }
    public var minor: String { return components[.minor] ?? "0" }
    public var patch: String { return components[.patch] ?? "0" }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
    }
    
    enum Component: Int, CaseIterable {
        case major
        case minor
        case patch
        
        var nextComponent: Component? {
            switch self {
            case .major: return .minor
            case .minor: return .patch
            case .patch: return nil
            }
        }
    }
    
    let components: [Component: String]
    
    public var versionString: String {
        Component.allCases.reduce("") { (result, component) -> String in
            guard let value = components[component] else { return result }
            guard !result.isEmpty else { return value }
            return result + "." + value
        }
    }
    
    public init?(versionString: String) {
        let strings = versionString.split(separator: ".").map { String($0) }
        switch strings.count {
        case 2:
            self.init(major: strings[0], minor: strings[1], patch: nil)
        case 3:
            self.init(major: strings[0], minor: strings[1], patch: strings[2])
        default:
            return nil
        }
    }
    
    public init(major: String, minor: String, patch: String?) {
        var components:[Component: String] = [
            .major: major,
            .minor: minor
        ]
        guard let patch = patch else {
            self.components = components
            return
        }
        components[.patch] = patch
        self.components = components
    }
}
