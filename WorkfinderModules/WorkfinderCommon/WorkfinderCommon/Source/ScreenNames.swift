
public enum TrackEvent: String {
    case sideMenuToggle                         // checked
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
    case mapPan                                 // not connected
    case mapPinch                               // not connected
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
    
    case companyDetailsScreenDidLoad            // checked
    case companyDetailsCloseTap                 // checked
    case companyDetailsApplyTap                 // checked
    case companyDetailsCompanyTabTap            // checked
    case companyDetailsDataTabTap               // checked
    case companyDetailsPeopleTabTap             // checked
    case companyDetailsDataDuedilLinkTap        // checked
    case companyDetailsDataLinkedinLinkTap      // checked
    case companyDetailsShareCompleted           // checked
    case companyDetailsShareCancelled           // checked

    case companyDetailsShowShareTap             // checked
    case companyDetailsFavouriteSwitchOn        // checked
    case companyDetailsFavouriteSwitchOff       // checked
    case companyDetailsShowMapTap               // checked
    case companyDetailsHideMapTap               // checked
    
    case letterCancelTap                        // checked
    case letterEditButtonTap                    // checked
    case letterTextTap                          // not implemented, directed to EditButtonTap
    case letterApplyTap                         // checked
    case letterTermsAndConditionsLinkTap        // checked
    case letterApplyButtonEnabled               // checked
    case letterApplyButtonDisabled              // checked
    
    case editLetterShowPersonalAttributesTap    // checked
    case editLetterShowJobRoleTap               // checked
    case editLetterShowAvailabilityDatesTap     // checked
    case editLetterShowAvailabilityHoursTap     // checked
    case editLetterShowEmploymentSkillsTap      // checked
    case editLetterShowMotivationTextTap        // checked
    case motivationTextDefaultSelected          // checked
    case motivationTextCustomSelected           // checked
    case editLetterUpdateLetterArrowTap         // checked
    case editLetterUpdateLetterButtonTap        // checked
    
    case personalInformationAcceptTermsOfServiceSwitchOn    // checked
    case personalInformationAcceptTermsOfServiceSwitchOff   // checked
    case personalInformationShowTermsOfServiceLinkTap       // checked
    case personalInformationCompleteInformationTap          // checked
    
    case addDocumentsSkipTap                                //  checked
    case addDocumentsUploadTap                              //  checked
    case addDocumentsAddDocumentTap                         //  checked
    case addDocumentsViewDocumentTap                        //  checked
    case addDocumentsDeleteDocumentTap                      //  checked
    case addDocumentsShowDocumentOptionsPopupTap            //  checked
    case addDocumentsCVInfoTap                              //  checked
    
    case addDocumentTypeTap
    case addDocumentCameraTap                               // checked
    case addDocumentDidCaptureCamera                        // checked
    case addDocumentPhotoLibraryTap                         // checked
    case addDocumentDidCaptureLibrary                       // checked
    case addDocumentFileSystemTap                           // checked
    case addDocumentDidCaptureFile                          // checked
    case addDocumentURLTap                                  // checked
    case addDocumentDidCaptureUrl                           // checked
    case addDocumentBackTap
    
    case applyHoorayMessagesTap                 // checked
    case applyHooraySearchTap                   // checked
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
