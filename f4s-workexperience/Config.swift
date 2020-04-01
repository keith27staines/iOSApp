import WorkfinderCommon

public struct Config {
    public static let wexApiKey = "eTo0oeh4Yeen1oy7iDuv"
    #if STAGING
    // Development & testing config
    public static let environmentName = "STAGING"
    public static var workfinderApiBase = "http://workfinder-develop.eu-west-2.elasticbeanstalk.com/v3/"
    #else
    // Default to production (live) config
    public static let environmentName = "PRODUCTION"
    public static var workfinderApiBase = "https://workfinder-master.eu-west-2.elasticbeanstalk.com/v3/"
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
