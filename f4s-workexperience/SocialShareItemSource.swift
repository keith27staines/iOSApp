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

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.message {
            return self.getTextForType(socialShareType: .sms)
        } else if activityType == UIActivityType.mail {
            return self.getTextForType(socialShareType: .email)
        } else if activityType == UIActivityType.postToTwitter {
            return self.getTextForType(socialShareType: .twitter)
        } else if activityType == UIActivityType.postToFacebook {
            return self.getTextForType(socialShareType: .facebook)
        }
        return self.getTextForType(socialShareType: .email)
    }

    func activityViewController(_: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.message {
            return ""
        } else if activityType == UIActivityType.mail {
            return self.getSubjectTextForType(socialShareType: .email)
        } else if activityType == UIActivityType.postToTwitter {
            return ""
        } else if activityType == UIActivityType.postToFacebook {
            return ""
        }
        return ""
    }

    func activityViewController(_: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.message {
            return SocialShare.sms.rawValue
        } else if activityType == UIActivityType.mail {
            return SocialShare.email.rawValue
        } else if activityType == UIActivityType.postToTwitter {
            return SocialShare.twitter.rawValue
        } else if activityType == UIActivityType.postToFacebook {
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
