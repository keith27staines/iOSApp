//
//  Errors.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 12/2/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation

// Update error messages according to API changes and personalized messages
struct Errors {
    static let CreatePlacementCallErrors: CreatePlacementErrors = CreatePlacementErrors()
    static let UpdatePlacementCallErrors: UpdatePlacementErrors = UpdatePlacementErrors()
    static let CreateProfileCallErrors: CreateProfileErrors = CreateProfileErrors()
    static let GeneralCallErrors: GeneralErrors = GeneralErrors()
    static let VoucherCallErrors: VoucherErrors = VoucherErrors()
    static let UpdateProfileCallErrors: UpdateProfileErrors = UpdateProfileErrors()
    static let PushNotificationsCallErrors: PushNotificationsErrors = PushNotificationsErrors()
    static let ShortlistCallErrors: ShortlistErrors = ShortlistErrors()
}

struct CreatePlacementErrors {
    let VendorUuidRequired: CallError = CallError(code: "1.1", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Vendor uuid is required.", comment: ""), appErrorMessageTitle: "")
    let VendorUuidNotExist: CallError = CallError(code: "1.2", serverErrorMessage: "Vendor uuid not exist", appErrorMessage: NSLocalizedString("Please enter a valid vendor uuid.", comment: ""), appErrorMessageTitle: "")
    let CompanyUuidRequired: CallError = CallError(code: "1.3", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Company uuid is required.", comment: ""), appErrorMessageTitle: "")
    let CompanyUuidNotExist: CallError = CallError(code: "1.4", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid company uuid.", comment: ""), appErrorMessageTitle: "")
    let PlacementAlreadyExist: CallError = CallError(code: "1.5", serverErrorMessage: "Placement already exists", appErrorMessage: NSLocalizedString("Placement already exists", comment: ""), appErrorMessageTitle: "")
    let CannotApplyToPlacement: CallError = CallError(code: "1.6", serverErrorMessage: "Cannot apply to the same company within 60 days", appErrorMessage: NSLocalizedString("Cannot apply to the same company within 60 days", comment: ""), appErrorMessageTitle: "")
    let TooManyPlacementInProgress: CallError = CallError(code: "1.7", serverErrorMessage: "Too many placements in progress", appErrorMessage: NSLocalizedString("Too many placements in progress.", comment: ""), appErrorMessageTitle: "")
}

struct UpdatePlacementErrors {
    let VendorUuidRequired: CallError = CallError(code: "3.1", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Vendor uuid is required.", comment: ""), appErrorMessageTitle: "")
    let VendorUuidNotExist: CallError = CallError(code: "3.2", serverErrorMessage: "Vendor uuid not exist", appErrorMessage: NSLocalizedString("Please enter a valid vendor uuid.", comment: ""), appErrorMessageTitle: "")
    let CompanyUuidRequired: CallError = CallError(code: "3.3", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Company uuid is required.", comment: ""), appErrorMessageTitle: "")
    let CompanyUuidNotExist: CallError = CallError(code: "3.4", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid company uuid.", comment: ""), appErrorMessageTitle: "")
    let CoverLetterUuidRequired: CallError = CallError(code: "3.5", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Cover letter uuid is required.", comment: ""), appErrorMessageTitle: "")
    let CoverLetterUuidNotExist: CallError = CallError(code: "3.6", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid cover letter uuid.", comment: ""), appErrorMessageTitle: "")
    let StartDateRequired: CallError = CallError(code: "3.7", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Start date is required.", comment: ""), appErrorMessageTitle: "")
    let StartDateNotExist: CallError = CallError(code: "3.8", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid start date.", comment: ""), appErrorMessageTitle: "")
    let EndDateRequired: CallError = CallError(code: "3.9", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("End date is required.", comment: ""), appErrorMessageTitle: "")
    let EndDateNotExist: CallError = CallError(code: "3.10", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid end date.", comment: ""), appErrorMessageTitle: "")
    let JobRoleRequired: CallError = CallError(code: "3.11", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Job role is required.", comment: ""), appErrorMessageTitle: "")
    let JobRoleNotExist: CallError = CallError(code: "3.12", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid job role.", comment: ""), appErrorMessageTitle: "")
    let AttributesRequired: CallError = CallError(code: "3.13", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Attribute list is required.", comment: ""), appErrorMessageTitle: "")
    let AttributesNotExist: CallError = CallError(code: "3.14", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid attribute list.", comment: ""), appErrorMessageTitle: "")
    let SkillsRequired: CallError = CallError(code: "3.15", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Skills list is required.", comment: ""), appErrorMessageTitle: "")
    let SkillsNotExist: CallError = CallError(code: "3.16", serverErrorMessage: "Invalid value.", appErrorMessage: NSLocalizedString("Please enter a valid skill list.", comment: ""), appErrorMessageTitle: "")
    let CompanyUuidCannotApply: CallError = CallError(code: "3.17", serverErrorMessage: "Cannot change company during an application, please start a new application", appErrorMessage: NSLocalizedString("Cannot change company during an application, please start a new application.", comment: ""), appErrorMessageTitle: "")
}

struct CreateProfileErrors {
    let VendorUuidRequired: CallError = CallError(code: "2.1", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Please enter a valid vendor uuid.", comment: ""), appErrorMessageTitle: "")
    let VendorUuiAlreadyExist: CallError = CallError(code: "2.2", serverErrorMessage: "device with this vendor uuid already exists.", appErrorMessage: NSLocalizedString("Please enter a valid vendor uuid.", comment: ""), appErrorMessageTitle: "")
}

struct UpdateProfileErrors {
    let EmailRequired: CallError = CallError(code: "5.1", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Please enter a valid email.", comment: ""), appErrorMessageTitle: "")
    let DateOfBirthRequired: CallError = CallError(code: "5.2", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Please enter a valid date of birth.", comment: ""), appErrorMessageTitle: "")
    let ConsentorEmailRequired: CallError = CallError(code: "5.3", serverErrorMessage: "This field may not be blank.", appErrorMessage: NSLocalizedString("Please enter a valid consenter email.", comment: ""), appErrorMessageTitle: "")
    let VendorUuidNotExist: CallError = CallError(code: "5.4", serverErrorMessage: "This Device (a-vendor-uuid-1) does not exist", appErrorMessage: NSLocalizedString("Please enter a valid vendor uuid.", comment: ""), appErrorMessageTitle: "")
    let PlacementNotAssociated: CallError = CallError(code: "5.5", serverErrorMessage: "This Placement (b51cfca2-c95c-48eb-8dd1-95d66bc65663) is not associated with the current Device", appErrorMessage: NSLocalizedString("Placement is not associated with the current device.", comment: ""), appErrorMessageTitle: "")
    let LastNameRequired: CallError = CallError(code: "5.6", serverErrorMessage: "This field is required.", appErrorMessage: NSLocalizedString("Please enter a valid last name.", comment: ""), appErrorMessageTitle: "")
    let EmailNotValid: CallError = CallError(code: "5.7", serverErrorMessage: "Enter a valid email address.", appErrorMessage: NSLocalizedString("Please enter a valid email.", comment: ""), appErrorMessageTitle: "")
    let ConsentorEmailNotValid: CallError = CallError(code: "5.8", serverErrorMessage: "Enter a valid email address.", appErrorMessage: NSLocalizedString("Please enter a valid consenter email.", comment: ""), appErrorMessageTitle: "")
}

struct GeneralErrors {
    let DeserializationError: CallError = CallError(code: "0.1", serverErrorMessage: "Deserialization error", appErrorMessage: NSLocalizedString("An error has occured. Please try again", comment: ""), appErrorMessageTitle: "")
    let NetworkError: CallError = CallError(code: "0.2", serverErrorMessage: "No internet connection.", appErrorMessage: NSLocalizedString("You appear to be offline at the moment. Please try again later when you have a working internet connection.", comment: ""), appErrorMessageTitle: NSLocalizedString("No Data Connectivity", comment: ""))
    let GeneralError: CallError = CallError(code: "0.3", serverErrorMessage: "General error", appErrorMessage: NSLocalizedString("An error has occured. Please try again", comment: ""), appErrorMessageTitle: "")
}

struct VoucherErrors {
    let VoucherInvalid: CallError = CallError(code: "4.1", serverErrorMessage: "Voucher is invalid", appErrorMessage: NSLocalizedString("Voucher is invalid.", comment: ""), appErrorMessageTitle: "")
    let VoucherExpired: CallError = CallError(code: "4.2", serverErrorMessage: "Voucher is expired", appErrorMessage: NSLocalizedString("Voucher has expired.", comment: ""), appErrorMessageTitle: "")
    let VoucherWasUsed: CallError = CallError(code: "4.3", serverErrorMessage: "Voucher has already been used", appErrorMessage: NSLocalizedString("Voucher has already been used.", comment: ""), appErrorMessageTitle: "")
    let VoucherNotFound: CallError = CallError(code: "4.3", serverErrorMessage: "Not found.", appErrorMessage: NSLocalizedString("Voucher is invalid.", comment: ""), appErrorMessageTitle: "")
}

struct PushNotificationsErrors {
    let DeviceUnregistered: CallError = CallError(code: "6.1", serverErrorMessage: "Device has not been registered, so cannot be deregistered", appErrorMessage: NSLocalizedString("Failed to deregister device.", comment: ""))
}

struct ShortlistErrors {
    let TooManyCompanies: CallError = CallError(code: "7.1", serverErrorMessage: "Please remove a company from your favourites, in order to add a new company.", appErrorMessage: NSLocalizedString("Please remove a company from your favourites, in order to add a new company.", comment: ""), appErrorMessageTitle: "")
    let NotFoundFavorite: CallError = CallError(code: "7.2", serverErrorMessage: "Not found.", appErrorMessage: NSLocalizedString("The shortlist was not found.", comment: ""), appErrorMessageTitle: "")
}

// error code
// error message in order to compare from server
// error message to show
struct CallError {
    var code: String?
    var serverErrorMessage: String?
    var appErrorMessage: String?
    var appErrorMessageTitle: String?

    init(code: String = "", serverErrorMessage: String = "", appErrorMessage: String = "", appErrorMessageTitle: String = "") {
        self.code = code
        self.serverErrorMessage = serverErrorMessage
        self.appErrorMessage = appErrorMessage
        self.appErrorMessageTitle = appErrorMessageTitle
    }
}
