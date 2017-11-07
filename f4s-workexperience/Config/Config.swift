//
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

struct Config {
    #if STAGING

        // Development & testing config

        static let ENVIRONMENT = "DEV"
        static let BASE_URL = "https://staging.workfinder.com/api/v1"
        static let BASE_URL2 = "https://staging.workfinder.com/api/v2"
        static let ACTIVATION_CODE = "0000"
        static let ERRORDOMAIN = "F4SErrorDomain"
        static let REACHABILITY_URL = "www.google.com"

    #else

        // Default to production (live) config

        static let ENVIRONMENT = "PROD"
        static let BASE_URL = "https://www.workfinder.com/api/v1"
        static let BASE_URL2 = "https://www.workfinder.com/api/v2"
        static let ACTIVATION_CODE = "0000"
        static let ERRORDOMAIN = "F4SErrorDomain"
        static let REACHABILITY_URL = "www.google.com"

    #endif
}
