//
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

struct Config {
    
    enum EnvironmentType {
        case staging
        case production
    }
    
    static var environment: EnvironmentType {
        switch ENVIRONMENT {
        case "STAGING":
            return EnvironmentType.staging
        case "PRODUCTION":
            return EnvironmentType.production
        default:
            return EnvironmentType.production
        }
    }
    
    #if STAGING

        // Development & testing config

        static let ENVIRONMENT = "STAGING"
        static let BASE = "https://staging.workfinder.com/api"
        static let BASE_URL = "https://staging.workfinder.com/api/v1"
        static let BASE_URL2 = "https://staging.workfinder.com/api/v2"
        static let ACTIVATION_CODE = "0000"
        static let ERRORDOMAIN = "F4SErrorDomain"
        static let REACHABILITY_URL = "www.google.com"

    #else

        // Default to production (live) config

        static let ENVIRONMENT = "PRODUCTION"
        static let BASE = "https://www.workfinder.com/api"
        static let BASE_URL = "https://www.workfinder.com/api/v1"
        static let BASE_URL2 = "https://www.workfinder.com/api/v2"
        static let ACTIVATION_CODE = "0000"
        static let ERRORDOMAIN = "F4SErrorDomain"
        static let REACHABILITY_URL = "www.google.com"

    #endif
    
    static var apnsEnv: String {
        if self.apns == "sandbox" {
            return "dev"
        } else {
            if ENVIRONMENT == "STAGING" {
                return "staging"
            } else {
                return "production"
            }
        }
    }
    
    static var apns: String {
        #if DEBUG
            return "sandbox"
        #else
            return "production"
        #endif
        
    }
}
