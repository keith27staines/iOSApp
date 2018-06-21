//
//  DeserializationManager.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//
import SwiftyJSON

class DeserializationManager {
    
    // MARK:- singleton
    class var sharedInstance: DeserializationManager {
        struct Static {
            static let instance: DeserializationManager = DeserializationManager()
        }
        return Static.instance
    }

    // MARK:- placement
    func parseCreatePlacement(jsonOptional: JSON) -> Result<String> {
        if let placementUuid = jsonOptional["uuid"].string {
            return .value(Box(placementUuid))
        }

        if let _ = jsonOptional["errors"].dictionary {
            if let vendorUuidErrors = jsonOptional["errors"]["user_uuid"].array {
                if vendorUuidErrors.count > 0 {
                    if vendorUuidErrors[0].string == Errors.CreatePlacementCallErrors.VendorUuidRequired.serverErrorMessage {
                        return .deffinedError(Errors.CreatePlacementCallErrors.VendorUuidRequired)
                    }
                    return .deffinedError(Errors.CreatePlacementCallErrors.VendorUuidNotExist)
                }
            }

            if let companyUuidErrors = jsonOptional["errors"]["company_uuid"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.CreatePlacementCallErrors.CompanyUuidRequired.serverErrorMessage {
                        return .deffinedError(Errors.CreatePlacementCallErrors.CompanyUuidRequired)
                    }
                    if companyUuidErrors[0].string == Errors.CreatePlacementCallErrors.CompanyUuidNotExist.serverErrorMessage {
                        return .deffinedError(Errors.CreatePlacementCallErrors.CompanyUuidNotExist)
                    }
                }
            }
            if let allError = jsonOptional["errors"]["non_field_errors"].string {
                if allError == Errors.CreatePlacementCallErrors.PlacementAlreadyExist.serverErrorMessage {
                    return .deffinedError(Errors.CreatePlacementCallErrors.PlacementAlreadyExist)
                }
                if allError == Errors.CreatePlacementCallErrors.CannotApplyToPlacement.serverErrorMessage {
                    return .deffinedError(Errors.CreatePlacementCallErrors.CannotApplyToPlacement)
                }
                if allError == Errors.CreatePlacementCallErrors.TooManyPlacementInProgress.serverErrorMessage {
                    return .deffinedError(Errors.CreatePlacementCallErrors.TooManyPlacementInProgress)
                }
            }
        }

        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }


    func parseUpdatePlacement(jsonOptional: JSON) -> Result<String> {
        if let _ = jsonOptional["company_uuid"].string {
            return .value(Box("true"))
        }

        if let _ = jsonOptional["errors"].dictionary {
            if let vendorUuidErrors = jsonOptional["errors"]["user_uuid"].array {
                if vendorUuidErrors.count > 0 {
                    if vendorUuidErrors[0].string == Errors.UpdatePlacementCallErrors.VendorUuidRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.VendorUuidRequired)
                    }
                    return .deffinedError(Errors.UpdatePlacementCallErrors.VendorUuidNotExist)
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["company_uuid"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.CompanyUuidRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.CompanyUuidRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.CompanyUuidNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.CompanyUuidNotExist)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.CompanyUuidCannotApply.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.CompanyUuidCannotApply)
                    }
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["coverletter_uuid"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.CoverLetterUuidRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.CoverLetterUuidRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.CoverLetterUuidNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.CoverLetterUuidNotExist)
                    }
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["start_date"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.StartDateRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.StartDateRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.StartDateNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.StartDateNotExist)
                    }
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["end_date"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.EndDateRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.EndDateRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.EndDateNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.EndDateNotExist)
                    }
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["job_role"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.JobRoleRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.JobRoleRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.JobRoleNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.JobRoleNotExist)
                    }
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["attributes"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.AttributesRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.AttributesRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.AttributesNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.AttributesNotExist)
                    }
                }
            }
            if let companyUuidErrors = jsonOptional["errors"]["skills"].array {
                if companyUuidErrors.count > 0 {
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.SkillsRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.SkillsRequired)
                    }
                    if companyUuidErrors[0].string == Errors.UpdatePlacementCallErrors.SkillsNotExist.serverErrorMessage {
                        return .deffinedError(Errors.UpdatePlacementCallErrors.SkillsNotExist)
                    }
                }
            }
            if let _ = jsonOptional["errors"]["non_field_errors"].string {
                return .deffinedError(Errors.GeneralCallErrors.GeneralError)
            }
        }
        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }
    
    
    func parseRatePlacement(jsonOptional: JSON) -> Result<String> {
        
        if let _ = jsonOptional["value"].int {
            return .value(Box("succeeded"))
        }
        
        if let _ = jsonOptional["errors"].array {
            return .deffinedError(Errors.GeneralCallErrors.GeneralError)
        }
        
        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }
    
    func parseTimelinePlacement(jsonOptional: JSON) -> Result<[TimelinePlacement]> {

        if let placementsJsonList = jsonOptional.array {
            var timelinePlacementsList: [TimelinePlacement] = []
            for placementJson in placementsJsonList {
                var timelinePlacement = TimelinePlacement()
                if let placementUuid = placementJson["uuid"].string {
                    timelinePlacement.placementUuid = placementUuid
                }
                if let userUuid = placementJson["user_uuid"].string {
                    timelinePlacement.userUuid = userUuid
                }
                if let companyUuid = placementJson["company_uuid"].string {
                    timelinePlacement.companyUuid = companyUuid
                }
                if let threadUuid = placementJson["thread_uuid"].string {
                    timelinePlacement.threadUuid = threadUuid
                }
                if let isRead = placementJson["is_read"].bool {
                    timelinePlacement.isRead = isRead
                }
                if let state = placementJson["state"].string {
                    switch state
                    {
                    case "draft":
                        timelinePlacement.status = .draft
                        break
                    case "applied":
                        timelinePlacement.status = .applied
                        break
                    case "no_age":
                        timelinePlacement.status = .noAge
                        break
                    case "no_voucher":
                        timelinePlacement.status = .noVoucher
                        break
                    case "no_parental_consent":
                        timelinePlacement.status = .noParentalConsent
                        break
                    case "unsuccessful":
                        timelinePlacement.status = .unsuccessful
                        break
                    case "accepted":
                        timelinePlacement.status = .accepted
                        break
                    case "rejected":
                        timelinePlacement.status = .rejected
                        break
                    case "confirmed":
                        timelinePlacement.status = .confirmed
                        break
                    case "in_progress":
                        timelinePlacement.status = .inProgress
                        break
                    case "completed":
                        timelinePlacement.status = .completed
                        break
                    default:
                        timelinePlacement.status = .applied
                        break
                    }
                }
                if let _ = placementJson["latest_message"].dictionary {
                    var latestMessage = F4SMessage()
                    if let messageUuid = placementJson["latest_message"]["uuid"].string {
                        latestMessage.uuid = messageUuid
                    }
                    if let dateTime = placementJson["latest_message"]["datetime"].string, let date = Date.dateFromRfc3339(string: dateTime) {
                        latestMessage.dateTime = date
                    }
                    if let dateTimeRel = placementJson["latest_message"]["datetime_rel"].string {
                        latestMessage.relativeDateTime = dateTimeRel
                    }
                    if let content = placementJson["latest_message"]["content"].string {
                        latestMessage.content = content
                    }
                    if let senderUuid = placementJson["latest_message"]["sender"].string {
                        latestMessage.sender = senderUuid
                    }
                    timelinePlacement.latestMessage = latestMessage
                }
                timelinePlacementsList.append(timelinePlacement)
            }
            return .value(Box(timelinePlacementsList))
        }
        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }
}
