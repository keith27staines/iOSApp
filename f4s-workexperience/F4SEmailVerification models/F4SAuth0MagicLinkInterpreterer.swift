//
//  F4SAuth0MagicLinkInterpreterer.swift
//  AuthTest
//
//  Created by Keith Dev on 11/12/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import Foundation
import Auth0

public struct F4SCredentials {
    var accessToken: String?
    var idToken: String?
    public init(auth0Credentials: Credentials) {
        self.accessToken = auth0Credentials.accessToken
        self.idToken = auth0Credentials.idToken
    }
}

public struct F4SAuth0MagicLinkInterpreter {

    public static func isPasswordlessURL(url: URL?) -> Bool {
        guard let url = url else { return false }
        if let bundleId = bundleIdentifier() {
            if !doesPathOfURL(url, contain: bundleId) { return false }
        }
        guard let _ = passcode(from: url) else { return false }
        return true
    }
    
    public static func passcode(from url: URL) -> String? {
        guard let components = self.components(from: url) else { return nil }
        guard let items = components.queryItems else { return nil }
        guard let key = items.filter({ $0.name == "code" }).first, let passcode = key.value, Int(passcode) != nil else { return nil }
        return passcode
    }
}

extension F4SAuth0MagicLinkInterpreter {
    
    static func doesPathOfURL(_ url: URL, contain string: String) -> Bool {
        guard let components = components(from: url) else { return false }
        let path = components.path.lowercased()
        return path.contains(string.lowercased())
    }
    
    static func components(from url: URL) -> URLComponents? {
        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }

    static func bundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }
}

