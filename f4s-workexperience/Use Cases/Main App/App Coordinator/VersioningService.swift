
import Foundation

class WorkfinderVersionReporter  {
    var releaseVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary?["CFBundleVersion"] as? String
    }
}


