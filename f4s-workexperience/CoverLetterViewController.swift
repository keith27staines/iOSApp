//
//  CoverLetterViewController.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit
import Mustache
import Reachability

class CoverLetterViewController: UIViewController {
    @IBOutlet weak var templateTextView: UITextView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    var editCoverLetterButton: UIButton?

    var currentTemplate: F4STemplate?
    var selectedTemplateChoices: [F4STemplateBlank] = []
    var applicationContext: F4SApplicationContext!
    
    lazy var templateService: F4STemplateServiceProtocol = {
        return F4STemplateService()
    }()
    
    lazy var placementService: F4SPlacementServiceProtocol = {
        return F4SPlacementService()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppereance()
        getLatestTemplate()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        adjustNavigationBar()
        self.templateTextView.isScrollEnabled = false
        self.selectedTemplateChoices = TemplateChoiceDBOperations.sharedInstance.getSelectedTemplateBlanks()
        applicationContext.availabilityPeriod = F4SAvailabilityPeriod.fromUserDefaults()
        loadTemplate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.templateTextView.isScrollEnabled = true
    }
}

extension CoverLetterViewController: EditCoverLetterViewControllerDelegate {
    func editCoverLetterDidUpdate(applicationContext: F4SApplicationContext) {
        self.applicationContext = applicationContext
        self.applicationContext.availabilityPeriod?.saveToUserDefaults()
    }
}

// MARK: - adjust appereance
extension CoverLetterViewController {
    func adjustAppereance() {
        adjustNavigationBar()
        setApplyButton()
        setBottomView()
        addGestureRecognizerToTextView()
    }

    func addGestureRecognizerToTextView() {
        let tapTextView = UITapGestureRecognizer(target: self, action: #selector(textViewTouched))
        tapTextView.delegate = self
        self.templateTextView.addGestureRecognizer(tapTextView)
    }

    func adjustNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonTouched))
        navigationItem.leftBarButtonItem = leftButton

        let editCoverLetterTitle = NSLocalizedString("Edit Cover Letter", comment: "")
        let editCoverLetterFont: UIFont = UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular)
        editCoverLetterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        editCoverLetterButton?.layer.cornerRadius = 10
        editCoverLetterButton?.layer.masksToBounds = true
        editCoverLetterButton?.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        editCoverLetterButton?.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        editCoverLetterButton?.setTitleColor(UIColor.white, for: .normal)
        editCoverLetterButton?.setTitleColor(UIColor.white, for: .highlighted)
        editCoverLetterButton?.addTarget(self, action: #selector(CoverLetterViewController.editCoverLetterButtonTouched), for: UIControlEvents.touchUpInside)
        editCoverLetterButton?.setAttributedTitle(NSAttributedString(string: editCoverLetterTitle,
                                                                     attributes: [
                                                                         NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.white),
                                                                         NSAttributedStringKey.font: editCoverLetterFont,
        ]), for: UIControlState.normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editCoverLetterButton!)
        
        styleNavigationController(titleColor: UIColor.black, backgroundColor: UIColor.white, tintColor: UIColor.black, useLightStatusBar: false)
    }

    func setApplyButton() {
        let applyText = NSLocalizedString("Apply", comment: "")
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: applyButton)
        applyButton.setTitle(applyText, for: .normal)
    }

    func setBottomView() {
        let termsAndConditionsApplyText = NSLocalizedString("By applying you are agreeing to our ", comment: "")
        let termsAndConditionsText = NSLocalizedString("Terms and Conditions & Privacy Policy", comment: "")
        let formattedString = NSMutableAttributedString()
        formattedString.append(NSAttributedString(string: termsAndConditionsApplyText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.warmGrey)]))
        formattedString.append(NSAttributedString(string: termsAndConditionsText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.warmGrey)]))
        self.termsAndConditionsButton.setAttributedTitle(formattedString, for: .normal)
        self.termsAndConditionsButton.titleLabel?.textAlignment = .center
    }

    func setButtonStates(enableApply: Bool) {
        if enableApply {
            // all data is set
            self.applyButton.isEnabled = true
            if let rightBarButton = self.editCoverLetterButton {
                rightBarButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
                rightBarButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
            }
        } else {
            self.applyButton.isEnabled = false
            if let rightBarButton = self.editCoverLetterButton {
                rightBarButton.setBackgroundColor(color: UIColor(netHex: Colors.orangeNormal), forUIControlState: .normal)
                rightBarButton.setBackgroundColor(color: UIColor(netHex: Colors.orangeActive), forUIControlState: .highlighted)
            }
        }
    }
}

// MARK: - template helper
extension CoverLetterViewController {
    func loadTemplate() {
        setButtonStates(enableApply: false)
        self.removeInvalidDateFields()
        guard let currentTemplate = self.currentTemplate else {
            return
        }
        do {
            var allowApply = true;
            let templateToLoad = try Template(string: currentTemplate.template)
            var data: [String: Any] = [:]
            for blank in currentTemplate.blanks {
                let name = blank.name
                if let indexOfSelectedBlank = self.selectedTemplateChoices.index(where: { (otherBlank) -> Bool in
                    if name == otherBlank.name {
                        return true
                    }
                    return false
                })
                
                {
                    let selectedBlank = self.selectedTemplateChoices[indexOfSelectedBlank]
                    let fillStrings = getFillStrings(selectedChoices: selectedBlank.choices, availableChoices: blank.choices)

                    if let grammaticalString = F4SGrammar.list(fillStrings) {
                        let htmlDecodedString = grammaticalString.htmlDecode()
                        data[blank.name] = populatedField(with: htmlDecodedString)
                    } else {
                        data[blank.name] = String(format: "%@(%@)%@", TemplateCustomParse.startPlaceholder.rawValue, blank.placeholder, TemplateCustomParse.endPlaceholder.rawValue)
                        allowApply = false
                    }

                } else {
                    data[blank.name] = String(format: "%@(%@)%@", TemplateCustomParse.startPlaceholder.rawValue, blank.placeholder, TemplateCustomParse.endPlaceholder.rawValue)
                    allowApply = false
                }
            }
            
            if let company = self.applicationContext.company {
                data["company_name"] = String(format: "%@%@%@", TemplateCustomParse.startBold.rawValue, company.name, TemplateCustomParse.endBold.rawValue)
            }
            let renderingTemplate = try templateToLoad.render(data)
            self.templateTextView.attributedText = self.getAttributedStringForTemplate(template: renderingTemplate.htmlDecode())
            self.templateTextView.isEditable = false
            setButtonStates(enableApply: allowApply)

            let editor = editCoverLetterViewController()!
            editor.configureTemplate()
            let firstDate = editor.getStartDate()
            let lastDate = editor.getEndDate()
            let calendar = F4SCalendar()
            let firstDay = firstDate != nil ? F4SCalendarDay(cal:calendar, date: firstDate!) : nil
            let lastDay = lastDate != nil ? F4SCalendarDay(cal: calendar, date: lastDate!) : nil
            let previousDaysHoursModel = applicationContext.availabilityPeriod?.daysAndHours
            applicationContext.availabilityPeriod = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: previousDaysHoursModel)
            
        } catch {
            MessageHandler.sharedInstance.display(error.localizedDescription, parentCtrl: self)
            log.debug("error on parsing template")
        }
    }
    
    func getFillStrings(selectedChoices: [F4SChoice], availableChoices: [F4SChoice]) -> [String] {
        var fillStrings = [String]()
        for selectedChoice in selectedChoices {
            if let indexOfChoice = availableChoices.index(where: { $0.uuid == selectedChoice.uuid }) {
                fillStrings.append(availableChoices[indexOfChoice].value)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .none
                dateFormatter.dateFormat = "dd MMM yyyy"
                if let date = Date.dateFromRfc3339(string: selectedChoice.uuid) {
                    fillStrings.append(dateFormatter.string(from: date))
                }
            }
        }
        return fillStrings
    }
    
    func getAttributedStringForTemplate(template: String) -> NSMutableAttributedString {
        // normal font
        var customMutableAttributedString: [([NSAttributedStringKey: Any], NSRange)] = []

        var intermediateTemplateString: String = template.replacingOccurrences(of: "\r", with: "")
        // find first selection
        while true {
            var smalestIndex: Int = intermediateTemplateString.count
            var customParse: TemplateCustomParse?
            if let placeholder = intermediateTemplateString.index(of: TemplateCustomParse.startPlaceholder.rawValue) as Int? {
                if placeholder < smalestIndex {
                    // first attribute is one with placeholder
                    smalestIndex = placeholder
                    customParse = TemplateCustomParse.startPlaceholder
                }
            }
            if let selected = intermediateTemplateString.index(of: TemplateCustomParse.startSelected.rawValue) as Int? {
                if selected < smalestIndex {
                    // first attribute is one with one already selected
                    smalestIndex = selected
                    customParse = TemplateCustomParse.startSelected
                }
            }
            if let bold = intermediateTemplateString.index(of: TemplateCustomParse.startBold.rawValue) as Int? {
                if bold < smalestIndex {
                    // first attribute is one with one already selected
                    smalestIndex = bold
                    customParse = TemplateCustomParse.startBold
                }
            }

            if smalestIndex == intermediateTemplateString.count {
                // no more data to set
                break
            }

            // remove start string
            guard let customParseEnum = customParse,
                let customParseValue = customParse?.rawValue else {
                continue
            }

            var temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: customParseValue, withString: "")
            intermediateTemplateString = temp
            switch customParseEnum
            {
            case .startSelected:
                // should be colored with green

                // find the end selected string
                if let endSelected = intermediateTemplateString.index(of: TemplateCustomParse.endSelected.rawValue) as Int? {
                    // remove endSelectedString
                    temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: TemplateCustomParse.endSelected.rawValue, withString: "")
                    intermediateTemplateString = temp

                    // apply attributed text for that range
                    customMutableAttributedString.append(([NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.mediumGreen)], range: NSRange(location: smalestIndex, length: endSelected - smalestIndex)))
                }
                break
            case .startPlaceholder:
                // should be colored with orange

                // find the end placeholder string
                if let endPlaceholder = intermediateTemplateString.index(of: TemplateCustomParse.endPlaceholder.rawValue) as Int? {
                    // remove endSelectedString
                    temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: TemplateCustomParse.endPlaceholder.rawValue, withString: "")
                    intermediateTemplateString = temp

                    // apply attributed text for that range
                    customMutableAttributedString.append(([NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.orangeNormal)], range: NSRange(location: smalestIndex, length: endPlaceholder - smalestIndex)))
                }
                break
            case .startBold:
                // should be bold

                // find the end bold string
                if let endBold = intermediateTemplateString.index(of: TemplateCustomParse.endBold.rawValue) as Int? {
                    // remove endSelectedString
                    temp = intermediateTemplateString.stringByReplacingFirstOccurrenceOfString(target: TemplateCustomParse.endBold.rawValue, withString: "")
                    intermediateTemplateString = temp

                    // apply attributed text for that range
                    customMutableAttributedString.append(([NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor.black], range: NSRange(location: smalestIndex, length: endBold - smalestIndex)))
                }
                break
            default:
                // other
                break
            }
        }

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 34 - UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular).lineHeight
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: intermediateTemplateString, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black])
        for attrString in customMutableAttributedString {
            mutableAttributedString.addAttributes(attrString.0, range: attrString.1)
        }

        return mutableAttributedString
    }

    func getValueForUuid(choices: [F4SChoice], uuid: String) -> String {
        if let indexOfChoice = choices.index(where: { $0.uuid == uuid }) {
            return choices[indexOfChoice].value
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd MMM yyyy"
        if let date = Date.dateFromRfc3339(string: uuid) {
            return dateFormatter.string(from: date)
        }
        return uuid
    }
    
    public func populatedField(with string: String) -> String {
        return TemplateCustomParse.startSelected.rawValue + string + TemplateCustomParse.endSelected.rawValue
    }

    enum TemplateCustomParse: String {
        case startPlaceholder = "{{startPlaceholder"
        case endPlaceholder = "endPlaceholder}}"
        case startSelected = "{{startSelected"
        case endSelected = "endSelected}}"
        case startBold = "{{startBold"
        case endBold = "endBold}}"
    }
}

// MARK: - user interaction
extension CoverLetterViewController {
    @objc func backButtonTouched() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func editCoverLetterButtonTouched() {
        if let navCtrl = self.navigationController {
            guard let ctrl = editCoverLetterViewController() else { return }
            ctrl.delegate = self
            navCtrl.pushViewController(ctrl, animated: true)
        }
    }
    
    func editCoverLetterViewController() -> EditCoverLetterViewController? {
        let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: nil)
        guard let editor = coverLetterStoryboard.instantiateViewController(withIdentifier: "EditCoverLetterCtrl") as? EditCoverLetterViewController else { return nil }
        editor.currentTemplate = currentTemplate
        editor.applicationContext = applicationContext
        return editor
    }

    @IBAction func applyButtonTouched(_: Any) {
        updatePlacement()
    }

    @IBAction func termsAndConditionsButtonTouched(_: Any) {
        if let navCtrl = self.navigationController {
            CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navCtrl, contentType: F4SContentType.terms)
        }
    }

    @objc func textViewTouched() {
        editCoverLetterButtonTouched()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CoverLetterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - calls
extension CoverLetterViewController {
    func getLatestTemplate() {
        log.debug("Entered getLatestTemplate")
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }
        editCoverLetterButton?.isEnabled = false
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        templateService.getTemplates { result in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.editCoverLetterButton?.isEnabled = true
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result
                {
                case .success(let templates):
                    strongSelf.currentTemplate = templates.first
                    strongSelf.loadTemplate()
                case let .error(error):
                    MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: {
                        
                    }, retryHandler: {
                        strongSelf.getLatestTemplate()
                    })
                }
            }
        }
    }
    
    func updatePlacement() {
        let availabilityWindow = getWorkAvailabilityWindowFromSelectedTemplate()
        
        guard availabilityWindow.status == .valid else {
            promptUserWithCorrectiveActionForAvailabilityWindow(availabilityWindow)
            return
        }

        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }

        guard let currentCompanyUuid = applicationContext.company?.uuid,
            var placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompanyUuid),
            let currentTemplateUuid = currentTemplate?.uuid else {
            return
        }
        applicationContext.availabilityPeriod?.saveToUserDefaults()
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        let templateToUpdate = F4STemplate(uuid: currentTemplateUuid, blanks: self.selectedTemplateChoices)
        placement.companyUuid = applicationContext.company?.uuid
        placement.userUuid = F4SUser.userUuidFromKeychain
        placement.interestList = [F4SInterest](InterestDBOperations.sharedInstance.interestsForCurrentUser())
        placementService.updatePlacement(placement: placement, template: templateToUpdate) { [weak self] (result) in
            guard let strongSelf = self else {
                MessageHandler.sharedInstance.hideLoadingOverlay()
                return
            }
            MessageHandler.sharedInstance.hideLoadingOverlay()
            switch result {
                
            case .error(let error):
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: strongSelf.updatePlacement)
            case .success(_):
                // succes + go to next page
                strongSelf.applicationContext.placement = placement
                if let navCtrl = strongSelf.navigationController, let applicationContext = strongSelf.applicationContext, let availabilityPeriod = applicationContext.availabilityPeriod  {
                    let calendarService = F4SPCalendarService(placementUuid: placement.placementUuid!)
                    let availabilityJson = availabilityPeriod.availabilityJson!
                    let data = try! JSONEncoder().encode(availabilityJson)
                    let jsonString = String(data: data, encoding: .utf8)!
                    print(jsonString)
                    calendarService.patchAvailabilityForPlacement(availabilityPeriods: availabilityJson, completion: { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(_):
                                CustomNavigationHelper.sharedInstance.pushProcessedMessages(navCtrl, applicationContext: applicationContext)
                            case .error(let networkError):
                                strongSelf.handleF4SNetworkError(networkError: networkError)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func handleF4SNetworkError(networkError: F4SNetworkError) {
        MessageHandler.sharedInstance.display(networkError, parentCtrl: self)
    }
    
    func handleAlamoFireServiceErrorResult(result: Result<String>) {
        switch result
        {
        case .value:
            break
        case let .error(error):
            MessageHandler.sharedInstance.display(error, parentCtrl: self)
            break
        case let .deffinedError(error):
            MessageHandler.sharedInstance.display(error, parentCtrl: self)
            break
        }
    }

    func removeStartDate() {
        if let index = indexForAttribute(ChooseAttributes.StartDate) {
            TemplateChoiceDBOperations.sharedInstance.removeTemplateWithName(name: selectedTemplateChoices[index].name)
            self.selectedTemplateChoices.remove(at: index)
        }
    }
    
    func removeEndDate() {
        if let index = indexForAttribute(ChooseAttributes.EndDate) {
            TemplateChoiceDBOperations.sharedInstance.removeTemplateWithName(name: selectedTemplateChoices[index].name)
            self.selectedTemplateChoices.remove(at: index)
        }
    }
    
    func removeInvalidDateFields() {
        let availability = getWorkAvailabilityWindowFromSelectedTemplate()
        if availability.status != .valid {
            removeStartDate()
            removeEndDate()
        }
    }

    func promptUserWithCorrectiveActionForAvailabilityWindow(_ availabilityWindow: WorkAvailabilityWindow) {
        var message: String = ""
        switch availabilityWindow.status {
        case .valid:
            break;
        case .invalidStartDateMissing, .invalidStartsTooEarly:
            message = NSLocalizedString("Please enter a valid start date.", comment: "")
        case .invalidEndDateMissing, .invalidEndsTooEarly:
            message = NSLocalizedString("Please enter a valid end date.", comment: "")
        }
        MessageHandler.sharedInstance.display(message, parentCtrl: self)
    }
    
    func getWorkAvailabilityWindowFromSelectedTemplate() -> WorkAvailabilityWindow {
        let startDate: Date? = getStartDateFromTemplate()
        let endDate: Date? = getEndDateFromTemplate()
        let now = Date()
        return WorkAvailabilityWindow(
            startDay: startDate,
            endDay: endDate,
            submission: now)
    }

    func getStartDateFromTemplate() -> Date? {
        guard let index = indexForAttribute(ChooseAttributes.StartDate) else {
            return nil
        }
        guard let choice = self.selectedTemplateChoices[index].choices.first else {
            return nil
        }
        return Date.dateFromRfc3339(string: choice.uuid)
    }
    
    func getEndDateFromTemplate() -> Date? {
        guard let index = indexForAttribute(ChooseAttributes.EndDate) else {
            return nil
        }
        guard let choice = self.selectedTemplateChoices[index].choices.first else {
            return nil
        }
        return Date.dateFromRfc3339(string: choice.uuid)
    }
    
    func indexForAttribute(_ attribute: ChooseAttributes) -> Int? {
        return self.selectedTemplateChoices.index(where: { $0.name == attribute.rawValue })
    }
    
}
