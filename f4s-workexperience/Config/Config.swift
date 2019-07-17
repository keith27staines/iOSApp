//
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

struct Config {
    static let wexApiKey = "eTo0oeh4Yeen1oy7iDuv"
    #if STAGING
    // Development & testing config
    static let environmentName = "STAGING"
    static let workfinderApiBase = "https://staging.workfinder.com/api"
    #else
    // Default to production (live) config
    static let environmentName = "PRODUCTION"
    static let workfinderApiBase = "https://www.workfinder.com/api"
    #endif
    
    enum EnvironmentType {
        case staging
        case production
    }
    
    static var environment: EnvironmentType {
        switch environmentName {
        case "STAGING":
            return EnvironmentType.staging
        case "PRODUCTION":
            return EnvironmentType.production
        default:
            return EnvironmentType.production
        }
    }
    
    static var apnsEnv: String {
        if self.apns == "sandbox" {
            return "staging" //"dev"
        } else {
            if environmentName == "STAGING" {
                return "staging"
            } else {
                return "production"
            }
        }
    }
    
    static var apns: String {
        if environmentName == "STAGING" {
            #if DEBUG
                return "sandbox"
            #else
                return "production"
            #endif
        } else {
            return "production"
        }
    }
}
