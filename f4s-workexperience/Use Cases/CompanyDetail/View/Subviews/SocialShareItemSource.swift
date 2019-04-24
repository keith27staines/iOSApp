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

class SocialShareItemSource: NSObject, UIActivityItemSource {
    var company: Company?

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == UIActivity.ActivityType.message {
            return self.getTextForType(socialShareType: .sms)
        } else if activityType == UIActivity.ActivityType.mail {
            return self.getTextForType(socialShareType: .email)
        } else if activityType == UIActivity.ActivityType.postToTwitter {
            return self.getTextForType(socialShareType: .twitter)
        } else if activityType == UIActivity.ActivityType.postToFacebook {
            return self.getTextForType(socialShareType: .facebook)
        }
        return self.getTextForType(socialShareType: .email)
    }

    func activityViewController(_: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if activityType == UIActivity.ActivityType.message {
            return ""
        } else if activityType == UIActivity.ActivityType.mail {
            return self.getSubjectTextForType(socialShareType: .email)
        } else if activityType == UIActivity.ActivityType.postToTwitter {
            return ""
        } else if activityType == UIActivity.ActivityType.postToFacebook {
            return ""
        }
        return ""
    }

    func activityViewController(_: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
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

    @objc func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return ""
    }

    func getTextForType(socialShareType: SocialShare = .other) -> String {
        let socialShareTemplate = DatabaseOperations.sharedInstance.getBusinessesSocialShareTemplateOfType(type: socialShareType)
        do {
            let templateToLoad = try Template(string: socialShareTemplate)
            var data: [String: Any] = [:]
            if let currentCompany = self.company {
                data["company"] = currentCompany.name
                data["company_link"] = currentCompany.companyUrl
                data["hashtag"] = currentCompany.hashtag
            }
            let renderingTemplate = try templateToLoad.render(data)
            return renderingTemplate
        } catch {
            return ""
        }
    }

    func getSubjectTextForType(socialShareType: SocialShare = .other) -> String {
        let socialShareTemplate = DatabaseOperations.sharedInstance.getBusinessesSocialShareSubjectTemplateOfType(type: socialShareType)
        do {
            let templateToLoad = try Template(string: socialShareTemplate)
            var data: [String: Any] = [:]
            if let currentCompany = self.company {
                data["company"] = currentCompany.name
                data["company_link"] = currentCompany.companyUrl
                data["hashtag"] = currentCompany.hashtag
            }
            let renderingTemplate = try templateToLoad.render(data)
            return renderingTemplate
        } catch {
            return ""
        }
    }
}
