import WorkfinderCommon

public struct Config {
    public static let wexApiKey = ""
    
    #if DEVELOP
    public static let environmentName = "DEVELOP"
    public static var workfinderApiBase = "https://develop.workfinder.com/v3/"
    #elseif STAGING
    public static let environmentName = "STAGING"
    public static var workfinderApiBase = "https://release.workfinder.com/v3/"
    #else
    // Default to production (live) config
    public static let environmentName = "PRODUCTION"
    public static var workfinderApiBase = "https://workfinder.com/v3/"
    #endif
    
    public static var environment: EnvironmentType {
        switch environmentName {
        case "DEVELOP":
            return EnvironmentType.develop
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
            return "sandbox"
        } else {
            if environmentName == "STAGING" {
                return "staging"
            } else {
                return "production"
            }
        }
    }
    
    public static var apns: String {
        #if DEBUG
            return "sandbox"
        #else
            return "production"
        #endif
    }
}
