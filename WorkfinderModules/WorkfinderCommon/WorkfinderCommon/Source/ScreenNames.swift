
public enum TrackEvent: String {
    case hamburgerMenuTap
    case sideMenuAboutWorkfinderLinkTap
    case sideMenuFAQLinkTap
    case sideMenuTermsAndConditionsLinkTap
    
    case messagesTabTap                         // added
    case messageShowThreadTap
    case messageThreadShowCompanyTap
    case messageThreadActionTap
    
    case recommendationsTabTap                  // added
    case recommendationsShowCompanyTap
    
    case favouritesTabTap                       // added
    case favouritesShowCompanyTap

    case searchTabTap                           // added
    case mapPan
    case mapPinch
    case mapPinButtonTap
    case mapPinShowCompanyTap
    case mapClusterTap
    case mapClusterShowCompanyTap
    case mapShowSearchTap
    case mapSearchByNameTap
    case mapSearchByLocationTap
    case mapShowFiltersButtonTap
    case mapFiltersCancelTap
    case mapFiltersRefineSearchTap
    
    case companyDetailsCancelTap
    case companyDetailsApplyTap
    case companyDetailsCompanyTabTap
    case companyDetailsDataTabTap
    case companyDetailsPeopleTabTap
    case companyDetailsDataDuedilLinkTap
    case companyDetailsDataLinkedinLinkTap

    case companyDetailsShowShareTap
    case companyDetailsFavouriteSwitchOn
    case companyDetailsFavouriteSwitchOff
    case companyDetailsShowMapTap
    case companyDetailsHideMapTap
    
    case letterCancelTap
    case letterEditButtonTap
    case letterTextTap
    case letterApplyTap
    case letterTermsAndConditionsLinkTap
    
    case editLetterShowPersonalAttributesTap
    case editLetterShowJobRoleTap
    case editLetterShowAvailabilityDatesTap
    case editLetterShowAvailabilityHoursTap
    case editLetterShowEmploymentSkillsTap
    case editLetterShowMotivationTextTap
    case motivationTextDefaultSelected
    case motivationTextCustomSelected
    case editLetterUpdateLetterArrowTap
    case editLetterUpdateLetterButtonTap
    case editLetterApplyButtonEnabled
    case editLetterApplyButtonDisabled
    case editLetterCancelTap
    case editLetterApplyTap
    case editLetterTermsAndConditionsLinkTap
    
    case personalInformationAcceptTermsOfServiceSwitchOn
    case personalInformationAcceptTermsOfServiceSwitchOff
    case personalInformationShowTermsOfServiceLinkTap
    case personalInformationCompleteInformationTap
    
    case addDocumentsSkipTap
    case addDocumentsUploadTap
    case addDocumentsShowDocumentMenuTap
    case addDocumentsViewDocumentTap
    case addDocumentsDeleteDocumentTap
    case addDocumentsShowOptionsTap
    case documentOptionsBackTap
    case documentOptionsShowTypeTap
    case documentOptionsShowCameraTap
    case documentOptionsShowPhotoLibraryTap
    case documentOptionsShowFileSystemTap
    case documentOptionsShowURLTap
    
    case applyHoorayMessagesTap
    case applyHooraySearchTap
}


public enum ScreenName: String {
    case map = "Map TAB"
    case companySearch = "Company Search POP"
    case companyClusterList = "Company Cluster List POP"
    case companyPin = "Company Pin POP"
    case favourites = "Favourites TAB"
    case recommendations = "Recommendations SCR"
    case messagesContainer = "Thread List SCR"
    case company = "Company Details SCR"
    case coverLetter = "Cover Letter SCR"
    case editLetter = "Edit Letter SCR"
    case selectSkills = "Select Skills SCR"
    case selectPersonalAttributes = "Select PersonalAttributes SCR"
    case selectAvailabilityDates = "Select Availability Dates SCR"
    case selectDaysOfWeek = "Select Days of Week SCR"
    case selectJobRole = "Select Job Role SCR"
    case personalDetails = "Personal Details SCR"
    case addDocumentsScreen = "Add Documents SCR"
    case notSpecified = "Not specified"
}
