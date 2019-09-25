//
//  SocialShareItemSource.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 12/7/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit
import Mustache
import WorkfinderCommon

public class SocialShareItemSource: NSObject, UIActivityItemSource {
    public var company: Company
    public var shareTemplateProvider: ShareTemplateProviderProtocol
    
    public init(company: Company, shareTemplateProvider: ShareTemplateProviderProtocol) {
        self.company = company
        self.shareTemplateProvider = shareTemplateProvider
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == UIActivity.ActivityType.message {
            return self.getTextForType(.sms)
        } else if activityType == UIActivity.ActivityType.mail {
            return self.getTextForType(.email)
        } else if activityType == UIActivity.ActivityType.postToTwitter {
            return self.getTextForType(.twitter)
        } else if activityType == UIActivity.ActivityType.postToFacebook {
            return self.getTextForType(.facebook)
        }
        return self.getTextForType(.email)
    }

    public func activityViewController(_: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if activityType == UIActivity.ActivityType.message {
            return ""
        } else if activityType == UIActivity.ActivityType.mail {
            return self.getSubjectTextForType(.email)
        } else if activityType == UIActivity.ActivityType.postToTwitter {
            return ""
        } else if activityType == UIActivity.ActivityType.postToFacebook {
            return ""
        }
        return ""
    }

    public func activityViewController(_: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        if activityType == UIActivity.ActivityType.message {
            return SocialShare.sms.rawValue
        } else if activityType == UIActivity.ActivityType.mail {
            return SocialShare.email.rawValue
        } else if activityType == UIActivity.ActivityType.postToTwitter {
            return SocialShare.twitter.rawValue
        } else if activityType == UIActivity.ActivityType.postToFacebook {
            return SocialShare.facebook.rawValue
        }
        return ""
    }

    @objc public func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return ""
    }
}

extension SocialShareItemSource {

    func getTextForType(_ type: SocialShare = .other) -> String {
        let templateString = shareTemplateProvider.getBusinessesSocialShareTemplateOfType(type)
        return renderTemplateFrom(socialShareTemplateString: templateString)
    }

    func getSubjectTextForType(_ type: SocialShare = .other) -> String {
        let templateString = shareTemplateProvider.getBusinessesSocialShareSubjectTemplateOfType(type)
        return renderTemplateFrom(socialShareTemplateString: templateString)
    }
    
    func renderTemplateFrom(socialShareTemplateString: String) -> String {
        do {
            let template = try Template(string: socialShareTemplateString)
            var data: [String: Any] = [:]
            data["company"] = company.name
            data["company_link"] = company.companyUrl
            data["hashtag"] = company.hashtag
            return try template.render(data)
        } catch {
            return ""
        }
    }
}

public protocol ShareTemplateProviderProtocol {
    func getBusinessesSocialShareTemplateOfType(_ type: SocialShare) -> String
    func getBusinessesSocialShareSubjectTemplateOfType(_ type: SocialShare) -> String
}
