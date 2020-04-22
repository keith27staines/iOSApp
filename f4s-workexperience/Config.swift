import WorkfinderCommon

public struct Config {
    public static let wexApiKey = ""
    #if STAGING
    // Development & testing config
    public static let environmentName = "STAGING"
    public static var workfinderApiBase = "https://develop.workfinder.com/v3/"
    #else
    // Default to production (live) config
    public static let environmentName = "PRODUCTION"
    public static var workfinderApiBase = "https://workfinder.com/v3/"
    #endif
    
    public static var environment: EnvironmentType {
        switch environmentName {
        case "STAGING":
            return EnvironmentType.staging
        case "PRODUCTION":
            return EnvironmentType.production
        default:
            return EnvironmentType.production
        }
    }
    
    public static var apnsEnv: String {
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
    
    public static var apns: String {
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
