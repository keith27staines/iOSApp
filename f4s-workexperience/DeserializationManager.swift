//
//  DeserializationManager.swift
//  f4s-workexperience
//
//  Created by Andreea Rusu on 26/04/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//
import SwiftyJSON

class DeserializationManager {
    class var sharedInstance: DeserializationManager {
        struct Static {
            static let instance: DeserializationManager = DeserializationManager()
        }
        return Static.instance
    }

    func parseCreateProfile(jsonOptional: JSON) -> Result<String> {
        if let userUuid = jsonOptional["uuid"].string {
            return .value(Box(userUuid))
        }

        if let _ = jsonOptional["errors"].dictionary {
            if let vendorUuidErrors = jsonOptional["errors"]["vendor_uuid"].array {
                if vendorUuidErrors.count > 0 {
                    if vendorUuidErrors[0].string == Errors.CreateProfileCallErrors.VendorUuidRequired.serverErrorMessage {
                        return .deffinedError(Errors.CreateProfileCallErrors.VendorUuidRequired)
                    }
                    if vendorUuidErrors[0].string == Errors.CreateProfileCallErrors.VendorUuiAlreadyExist.serverErrorMessage {
                        return .deffinedError(Errors.CreateProfileCallErrors.VendorUuiAlreadyExist)
                    }
                }
            }
            if let userUuidErrors = jsonOptional["errors"]["uuid"].array {
                if userUuidErrors.count > 0 {
                    return .deffinedError(Errors.GeneralCallErrors.GeneralError)
                }
            }
        }

        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseUpdateUserProfile(jsonOptional: JSON) -> Result<String> {

        if let userUuid = jsonOptional["uuid"].string {
            return .value(Box(userUuid))
        }

        if let _ = jsonOptional["errors"].dictionary {
            if let emailError = jsonOptional["errors"]["email"].array {
                if emailError.count > 0 {
                    if emailError[0].string == Errors.UpdateProfileCallErrors.EmailRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdateProfileCallErrors.EmailRequired)
                    }
                    if emailError[0].string == Errors.UpdateProfileCallErrors.EmailNotValid.serverErrorMessage {
                        return .deffinedError(Errors.UpdateProfileCallErrors.EmailNotValid)
                    }
                }
            }

            if let dateOfBirthError = jsonOptional["errors"]["date_of_birth"].array {
                if dateOfBirthError.count > 0 {
                    if dateOfBirthError[0].string == Errors.UpdateProfileCallErrors.DateOfBirthRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdateProfileCallErrors.DateOfBirthRequired)
                    }
                }
            }

            if let consentorError = jsonOptional["errors"]["consenter_email"].array {
                if consentorError.count > 0 {
                    if consentorError[0].string == Errors.UpdateProfileCallErrors.ConsentorEmailRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdateProfileCallErrors.ConsentorEmailRequired)
                    }
                    if consentorError[0].string == Errors.UpdateProfileCallErrors.ConsentorEmailNotValid.serverErrorMessage {
                        return .deffinedError(Errors.UpdateProfileCallErrors.ConsentorEmailNotValid)
                    }
                }
            }

            if let lastNameError = jsonOptional["errors"]["last_name"].array {
                if lastNameError.count > 0 {
                    if lastNameError[0].string == Errors.UpdateProfileCallErrors.LastNameRequired.serverErrorMessage {
                        return .deffinedError(Errors.UpdateProfileCallErrors.LastNameRequired)
                    }
                }
            }

            if let nonFieldErrors = jsonOptional["errors"]["non_field_errors"].array {
                if nonFieldErrors[0].string == Errors.UpdateProfileCallErrors.ConsentorEmailRequired.serverErrorMessage {
                    return .deffinedError(Errors.UpdateProfileCallErrors.ConsentorEmailRequired)
                }

                if nonFieldErrors[0].string == Errors.UpdateProfileCallErrors.VendorUuidNotExist.serverErrorMessage {
                    return .deffinedError(Errors.UpdateProfileCallErrors.VendorUuidNotExist)
                }

                if nonFieldErrors[0].string == Errors.UpdateProfileCallErrors.PlacementNotAssociated.serverErrorMessage {
                    return .deffinedError(Errors.UpdateProfileCallErrors.PlacementNotAssociated)
                }
            }
        }
        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseLatestDatabaseVersion(jsonOptional: JSON) -> Result<CompanyDatabaseMeta> {
        if let created = jsonOptional["created"].string {
            var companyDatabaseMeta = CompanyDatabaseMeta()
            companyDatabaseMeta.created = created

            if let url = jsonOptional["url"].string {
                companyDatabaseMeta.url = url
            }

            return .value(Box(companyDatabaseMeta))
        }

        if let _ = jsonOptional["errors"].dictionary {
            if let _ = jsonOptional["errors"]["created"].array {
                return .error("created error")
            }
            if let _ = jsonOptional["errors"]["url"].array {
                return .error("url error")
            }
        }

        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

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

    func parseTemplate(jsonOptional: JSON) -> Result<[TemplateEntity]> {
        if let templateJsonList = jsonOptional.array {
            var templateList: [TemplateEntity] = []
            for templateJson in templateJsonList {
                var template: TemplateEntity = TemplateEntity()
                if let uuid = templateJson["uuid"].string {
                    template.uuid = uuid
                }
                if let temp = templateJson["template"].string {
                    template.template = temp
                }
                if let blanks = templateJson["blanks"].array {
                    var blankList: [TemplateBlank] = []
                    for blank in blanks {
                        var currentBlank: TemplateBlank = TemplateBlank()
                        if let name = blank["name"].string {
                            currentBlank.name = name
                        }
                        if let placeholder = blank["placeholder"].string {
                            currentBlank.placeholder = placeholder
                        }
                        if let optionType = blank["option_type"].string {
                            switch optionType
                            {
                            case "multiselect":
                                currentBlank.optionType = .multiSelect
                                break
                            case "select":
                                currentBlank.optionType = .select
                                break
                            default:
                                currentBlank.optionType = .date
                                break
                            }
                        }
                        if let maxChoice = blank["max_choice"].int {
                            currentBlank.maxChoice = maxChoice
                        }
                        if let initial = blank["initial"].string {
                            currentBlank.initial = initial
                        }
                        if let optionsJsonList = blank["option_choices"].array {
                            var optionsList: [Choice] = []
                            for option in optionsJsonList {
                                var currentOption: Choice = Choice()
                                if let uuid = option["uuid"].string {
                                    currentOption.uuid = uuid
                                }
                                if let value = option["value"].string {
                                    currentOption.value = value
                                }
                                optionsList.append(currentOption)
                            }
                            currentBlank.choices = optionsList
                        }
                        blankList.append(currentBlank)
                    }
                    template.blank = blankList
                }
                templateList.append(template)
            }
            return .value(Box(templateList))
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

    func parseContent(jsonOptional: JSON) -> Result<[ContentEntity]> {
        if let contentJsonList = jsonOptional.array {
            var contentList: [ContentEntity] = []
            for contentJson in contentJsonList {
                var content: ContentEntity = ContentEntity()
                if let title = contentJson["title"].string {
                    content.title = title
                }
                if let url = contentJson["url"].string {
                    content.url = url
                }
                if let slug = contentJson["slug"].string {
                    switch slug
                    {
                    case ContentType.terms.rawValue:
                        content.slug = .terms
                        break
                    case ContentType.faq.rawValue:
                        content.slug = .faq
                        break
                    case ContentType.about.rawValue:
                        content.slug = .about
                        break
                    case ContentType.voucher.rawValue:
                        content.slug = .voucher
                        break
                    case ContentType.consent.rawValue:
                        content.slug = .consent
                        break
                    case ContentType.about.rawValue:
                        content.slug = .about
                        break
                    default:
                        content.slug = .company
                        break
                    }

                    contentList.append(content)
                }
            }
            return .value(Box(contentList))
        }
        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseVoucher(jsonOptional: JSON) -> Result<String> {

        if let voucherStatus = jsonOptional["status"].string {
            return .value(Box(voucherStatus))
        }

        if let _ = jsonOptional["errors"].dictionary {

            if let voucherErrors = jsonOptional["errors"]["status"].string {

                if voucherErrors == Errors.VoucherCallErrors.VoucherExpired.serverErrorMessage {
                    return .deffinedError(Errors.VoucherCallErrors.VoucherExpired)
                }
                if voucherErrors == Errors.VoucherCallErrors.VoucherInvalid.serverErrorMessage {
                    return .deffinedError(Errors.VoucherCallErrors.VoucherInvalid)
                }
                if voucherErrors == Errors.VoucherCallErrors.VoucherWasUsed.serverErrorMessage {
                    return .deffinedError(Errors.VoucherCallErrors.VoucherWasUsed)
                }
            }

            if let voucherError = jsonOptional["errors"]["non_field_errors"].string {
                if voucherError == Errors.VoucherCallErrors.VoucherNotFound.serverErrorMessage {
                    return .deffinedError(Errors.VoucherCallErrors.VoucherNotFound)
                }

                return .deffinedError(Errors.GeneralCallErrors.GeneralError)
            }
        }
        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseEnablePushNotification(jsonOptional: JSON) -> Result<String> {

        if let notificationsStatus = jsonOptional["enabled"].bool {
            return .value(Box(String(notificationsStatus)))
        }

        if let notificationsError = jsonOptional["errors"]["non_field_errors"].string {
            if notificationsError == Errors.PushNotificationsCallErrors.DeviceUnregistered.serverErrorMessage {
                return .deffinedError(Errors.PushNotificationsCallErrors.DeviceUnregistered)
            }
        }

        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseMessagesInThread(jsonOptional: JSON) -> Result<[Message]> {
        if let messages = jsonOptional["messages"].array {
            var messageList: [Message] = []
            for message in messages {
                var mess = Message()
                if let uuid = message["uuid"].string {
                    mess.uuid = uuid
                }
                if let dateTime = message["datetime"].string, let date = Date.dateFromRfc3339(string: dateTime) {
                    mess.dateTime = date
                }
                if let relativeDateTime = message["datetime_rel"].string {
                    mess.relativeDateTime = relativeDateTime
                }
                if let content = message["content"].string {
                    mess.content = content
                }
                if let sender = message["sender"].string {
                    mess.sender = sender
                }
                messageList.append(mess)
            }

            return .value(Box(messageList))
        }

        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseMessageOptions(jsonOptional: JSON) -> Result<[MessageOption]> {
        if let options = jsonOptional["options"].array {
            var optionsList: [MessageOption] = []
            for option in options {
                var opt = MessageOption()
                if let uuid = option["uuid"].string {
                    opt.uuid = uuid
                }
                if let value = option["value"].string {
                    opt.value = value
                }
                optionsList.append(opt)
            }
            return .value(Box(optionsList))
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
                    var latestMessage = Message()
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

    func parseUnreadMessagesCount(jsonOptional: JSON) -> Result<UserStatus> {
        var userStatus: UserStatus = UserStatus()
        if let count = jsonOptional["unread_count"].int {
            userStatus.unreadCount = count
        }

        if let unratedPlacements = jsonOptional["unrated"].array {
            var placementList: [String] = []
            for placement in unratedPlacements {
                if let placementString = placement.string {
                    placementList.append(placementString)
                }
            }
            userStatus.unratedPlacements = placementList
        }

        return .value(Box(userStatus))
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

    func parseShortlistCompany(jsonOptional: JSON) -> Result<Shortlist> {

        if let favoriteUuid = jsonOptional["uuid"].string {
            let shortlist = Shortlist(uuid: favoriteUuid)
            return .value(Box(shortlist))
        }

        if let nonFieldErrors = jsonOptional["errors"]["non_field_errors"].array {
            if nonFieldErrors[0].string == Errors.ShortlistCallErrors.TooManyCompanies.serverErrorMessage {
                return .deffinedError(Errors.ShortlistCallErrors.TooManyCompanies)
            }
        }

        return .deffinedError(Errors.GeneralCallErrors.DeserializationError)
    }

    func parseUnshortlistCompany(jsonOptional: JSON) -> Result<Bool> {

        if let nonFieldErrors = jsonOptional["errors"]["non_field_errors"].array {
            if nonFieldErrors[0].string == Errors.ShortlistCallErrors.NotFoundFavorite.serverErrorMessage {
                return .deffinedError(Errors.ShortlistCallErrors.NotFoundFavorite)
            }
        }

        return .value(Box(true))
    }
}
