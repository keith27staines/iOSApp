//
//  ApplicationDetailHeaderData.swift
//  WorkfinderApplications
//
//  Created by Keith on 23/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

struct ApplicationDetailHeaderData {
    var companyLogoUrlString: String?
    var companyName: String?
    var projectName: String?
    var companyLogoDefaultText: String? { companyName }
    
    init(application: Application?) {
        companyLogoUrlString = application?.logoUrl
        companyName = application?.companyName
        projectName = application?.projectName
    }
}
