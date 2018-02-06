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

    var currentTemplate: TemplateEntity?
    var selectedTemplateChoices: [TemplateBlank] = []
    var currentCompany: Company?

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppereance()
        getLatestTemplate()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.templateTextView.isScrollEnabled = false

        self.selectedTemplateChoices = TemplateChoiceDBOperations.sharedInstance.getTemplateChoicesForCurrentUser()
        setButtonStates()
        loadTemplate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.templateTextView.isScrollEnabled = true
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
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.white)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        let backButton = UIBarButtonItem(image: UIImage(named: "Back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(backButtonTouched))
        backButton.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = backButton

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
    }

    func setApplyButton() {
        let applyText = NSLocalizedString("Apply", comment: "")
        applyButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        applyButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        applyButton.setBackgroundColor(color: UIColor(netHex: Colors.whiteGreen), forUIControlState: .disabled)
        applyButton.setTitleColor(UIColor.white, for: .normal)
        applyButton.setTitleColor(UIColor.white, for: .highlighted)

        applyButton.layer.cornerRadius = 10
        applyButton.layer.masksToBounds = true
        applyButton.setAttributedTitle(NSAttributedString(string: applyText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.biggerMediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white]), for: .normal)
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

    func setButtonStates() {
        if let currentTemplate = self.currentTemplate {
            if self.selectedTemplateChoices.count == currentTemplate.blank.count {
                // all data is setted
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
}

// MARK: - template helper
extension CoverLetterViewController {
    func loadTemplate() {
        self.removeInvalidDateFields()
        guard let currentTemplate = self.currentTemplate else {
            return
        }
        do {
            let templateToLoad = try Template(string: currentTemplate.template)
            var data: [String: Any] = [:]
            for blank in currentTemplate.blank {
                if let indexOfSelectedBlank = self.selectedTemplateChoices.index(where: { (otherBlank) -> Bool in
                    if blank.name == otherBlank.name {
                        return true
                    }
                    return false
                })
                
                {
                    let selectedBlank = self.selectedTemplateChoices[indexOfSelectedBlank]
                    let fillStrings = getFillStrings(selectedChoices: selectedBlank.choices, availableChoices: blank.choices)

                    if let grammaticalString = F4SGrammar.list(fillStrings) {
                        data[blank.name] = populatedField(with: grammaticalString)
                    } else {
                        data[blank.name] = populatedField(with: blank.placeholder)
                    }

                } else {
                    data[blank.name] = String(format: "%@(%@)%@", TemplateCustomParse.startPlaceholder.rawValue, blank.placeholder, TemplateCustomParse.endPlaceholder.rawValue)
                }
            }
            if let company = self.currentCompany {
                data["company_name"] = String(format: "%@%@%@", TemplateCustomParse.startBold.rawValue, company.name, TemplateCustomParse.endBold.rawValue)
            }

            let renderingTemplate = try templateToLoad.render(data)
            self.templateTextView.attributedText = self.getAttributedStringForTemplate(template: renderingTemplate)
            self.templateTextView.isEditable = false
        } catch {
            log.debug("error on parsing template")
        }
    }
    
    func getFillStrings(selectedChoices: [Choice], availableChoices: [Choice]) -> [String] {
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

    func getValueForUuid(choices: [Choice], uuid: String) -> String {
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
        if let navCtrl = self.navigationController, let currentTemplate = currentTemplate {
            CustomNavigationHelper.sharedInstance.pushEditCoverLetter(navCtrl, currentTemplate: currentTemplate)
        }
    }

    @IBAction func applyButtonTouched(_: Any) {
        updatePlacement()
    }

    @IBAction func termsAndConditionsButtonTouched(_: Any) {
        if let navCtrl = self.navigationController {
            CustomNavigationHelper.sharedInstance.presentContentViewController(navCtrl: navCtrl, contentType: ContentType.terms)
        }
    }

    @objc func textViewTouched() {
        if let navCtrl = self.navigationController, let currentTemplate = currentTemplate {
            CustomNavigationHelper.sharedInstance.pushEditCoverLetter(navCtrl, currentTemplate: currentTemplate)
        }
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
        if let reachability = Reachability() {
            if !reachability.isReachableByAnyMeans {
                MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
                return
            }
        }

        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        TemplateService.sharedInstance.getTemplate {
            [weak self]
            _, result in
            guard let strongSelf = self else {
                return
            }
            MessageHandler.sharedInstance.hideLoadingOverlay()
            switch result
            {
            case let .value(boxedValue):
                DispatchQueue.main.async {
                    strongSelf.currentTemplate = boxedValue.value.first
                    strongSelf.loadTemplate()
                    strongSelf.setButtonStates()
                }
                break
            case let .error(error):
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                break
            case let .deffinedError(error):
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                break
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

        guard let currentCompanyUuid = currentCompany?.uuid,
            var placement = PlacementDBOperations.sharedInstance.getPlacementsForCurrentUserAndCompany(companyUuid: currentCompanyUuid),
            let currentTemplateUuid = currentTemplate?.uuid else {
            return
        }

        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        let templateToUpdate = TemplateEntity(uuid: currentTemplateUuid, blank: self.selectedTemplateChoices)
        placement.interestsList = [Interest](InterestDBOperations.sharedInstance.interestsForCurrentUser())
        PlacementService.sharedInstance.updatePlacement(placement: placement, template: templateToUpdate) {
            [weak self]
            _, result in
            guard let strongSelf = self else {
                MessageHandler.sharedInstance.hideLoadingOverlay()
                return
            }
            MessageHandler.sharedInstance.hideLoadingOverlay()
            switch result
            {
            case .value:
                // succes + go to next page
                if let navCtrl = strongSelf.navigationController, let company = strongSelf.currentCompany {
                    CustomNavigationHelper.sharedInstance.pushProcessedMessages(navCtrl, currentCompany: company)
                }
                break
            case let .error(error):
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                break
            case let .deffinedError(error):
                MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf)
                break
            }
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
