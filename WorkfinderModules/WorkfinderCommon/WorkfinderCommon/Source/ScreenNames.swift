
public enum TrackEvent: String {
    case hamburgerMenuTap
    case sideMenuAboutWorkfinderLinkTap         // checked
    case sideMenuFAQLinkTap                     // checked
    case sideMenuTermsAndConditionsLinkTap      // checked
    
    case messagesTabTap                         // checked
    case messageShowThreadTap                   // checked
    case messageThreadShowCompanyTap            // checked
    case messageThreadActionTap                 // checked
    
    case recommendationsTabTap                  // checked
    case recommendationsShowCompanyTap          // checked
    
    case favouritesTabTap                       // checked
    case favouritesShowCompanyTap               // checked

    case searchTabTap                           // checked
    case mapPan
    case mapPinch
    case mapPinButtonTap                        // checked
    case mapPinShowCompanyTap                   // checked
    case mapClusterTap                          // checked
    case mapClusterShowCompanyTap               // checked
    case mapShowSearchTap                       // checked
    case mapSearchByNameTap                     // checked
    case mapSearchByLocationTap                 // checked
    case mapSearchShowCompanyTap                // checked
    case mapSearchGotoLocationTap               // checked
    case mapShowFiltersButtonTap                // checked
    case mapFiltersCancelTap                    // checked
    case mapFiltersRefineSearchTap              // checked
    
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
