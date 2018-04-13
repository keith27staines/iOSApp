//
//  CoverLetterViewController.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/22/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

protocol EditCoverLetterViewControllerDelegate {
    func editCoverLetterDidUpdate(applicationContext: F4SApplicationContext)
}

class EditCoverLetterViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverLetterTableView: UITableView!

    fileprivate let coverLetterCellIdentifier = "CoverLetterIdentifier"
    fileprivate let datePickerCellIdentifier = "DatePickerCellIdentifier"
    fileprivate let bigFooterSize = CGFloat(56)
    fileprivate let smallFooterSize = CGFloat(21)
    fileprivate var numberOfRowsInSection2 = 2
    fileprivate let datePickerSize: CGFloat = 200
    
    var delegate: EditCoverLetterViewControllerDelegate!
    var applicationContext: F4SApplicationContext!

    var isVisibleStartDatePicker = false
    var isVisibleEndDatePicker = false

    var currentTemplate: TemplateEntity!
    var selectedTemplateBlanks: [TemplateBlank] = []
    var dateFormatter: DateFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppereance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
        coverLetterTableView.reloadData()
        configureTemplate()
        setUpdateButtonState()
    }
    
    func configureTemplate() {
        let previouslySelectedBlanks = TemplateChoiceDBOperations.sharedInstance.getSelectedTemplateBlanks()
        let templateBlanks = currentTemplate.blanks
        self.selectedTemplateBlanks = TemplateHelper.removeUnavailableChoices(from: previouslySelectedBlanks, templateBlanks: templateBlanks)
        
        for blank in selectedTemplateBlanks {
            var choiceList = [String]()
            for choice in blank.choices {
                choiceList.append(choice.uuid)
            }
            TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: blank.name, choiceList: choiceList)
        }
    }
}

extension EditCoverLetterViewController : F4SDaysAndHoursViewControllerDelegate {
    func didUpdateDaysAndHours(model: F4SDaysAndHoursModel) {
        var availabilityPeriod: F4SAvailabilityPeriod = applicationContext.availabilityPeriod ?? F4SAvailabilityPeriod(firstDay: nil, lastDay: nil, daysAndHours: nil)
        availabilityPeriod.daysAndHours = model
        applicationContext.availabilityPeriod = availabilityPeriod
        self.delegate.editCoverLetterDidUpdate(applicationContext: applicationContext)
    }
}

extension EditCoverLetterViewController :  F4SCalendarCollectionViewControllerDelegate {
    func calendarDidChangeRange(_ calendar: F4SCalendarCollectionViewController, firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        guard let firstDay = firstDay, let lastDay = lastDay else {
            self.saveDataForAttribute(data: "", attribute: .StartDate)
            self.saveDataForAttribute(data: "", attribute: .EndDate)
            return
        }
        if applicationContext.availabilityPeriod == nil {
            applicationContext.availabilityPeriod = F4SAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay, daysAndHours: nil)
        }
        applicationContext.availabilityPeriod?.firstDay = firstDay
        applicationContext.availabilityPeriod?.lastDay = lastDay
        
        let startDate = firstDay.interval.start
        let endDate = lastDay.interval.start
        self.saveDataForAttribute(data: startDate.dateToStringRfc3339()!, attribute: .StartDate)
        self.saveDataForAttribute(data: endDate.dateToStringRfc3339()!, attribute: .EndDate)
        coverLetterTableView.reloadRows(at: [NSIndexPath(row: 0, section: 2) as IndexPath], with: .none)
        self.delegate.editCoverLetterDidUpdate(applicationContext: applicationContext)
        setUpdateButtonState()
    }
}

// MARK: -UITableViewDelegate,UITableViewDataSource
extension EditCoverLetterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 5
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = EditableSection(rawValue: section) else { return 0 }
        return 1
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(44)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: coverLetterCellIdentifier, for: indexPath) as? EditCoverLetterTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor.white
        cell.arrowImageView.isHidden = false
        cell.arrowImageView.image = UIImage(named: "rightArrow")

        cell.editTextLabel.isHidden = false
        cell.editValueLabel.isHidden = false
        cell.arrowImageView.isHidden = false
        
        guard let editableSection = EditableSection(rawValue: indexPath.section) else { return cell }
        switch editableSection
        {
        case .personalAttributes:
            cell.editTextLabel.text = NSLocalizedString("Personal attributes", comment: "")
            let attributeValue = self.getValueForAttribute(attribute: .PersonalAttributes)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = "\(attributeValue) chosen"
            }

        case .jobRole:

            cell.editTextLabel.text = NSLocalizedString("Job role", comment: "")
            let attributeValue = self.getValueForAttribute(attribute: .JobRole)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = attributeValue
            }

        case .availabilityCalendar:
            cell.editTextLabel.text = NSLocalizedString("Availability dates", comment: "")
            let startDate = getStartDate()
            let endDate = getEndDate()
            cell.editValueLabel.text = descriptorForDates(start: startDate, end: endDate)
            
        case .availabilityHours:
            cell.editTextLabel.text = NSLocalizedString("Availability days/hours", comment: "")
            cell.editValueLabel.text = "(optional) Choose"

        case .skills:

            cell.editTextLabel.text = NSLocalizedString("Employment skills", comment: "")
            let attributeValue = self.getValueForAttribute(attribute: .EmploymentSkills)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = "\(attributeValue) chosen"
            }
        }

        cell.editValueLabel.attributedText = NSAttributedString(string: cell.editValueLabel.text!, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.mediumGray)])

        return cell
    }
    
    func descriptorForDates(start: Date?, end: Date?) -> String {
        guard let start = start, let end = end else {
            return "Choose"
        }
        let txtStart = dateFormatter!.string(from: start)
        let txtEnd = dateFormatter!.string(from: end)
        if txtStart == txtEnd {
            return txtStart
        } else {
            return txtStart + " | " + txtEnd
        }
    }
    
    func getStartDate() -> Date? {
        let startDateString = self.getValueForAttribute(attribute: .StartDate)
        if !startDateString.isEmpty, let startDate = Date.dateFromRfc3339(string: startDateString) {
            return startDate
        }
        return nil
    }
    
    func getEndDate() -> Date? {
        let endDateString = self.getValueForAttribute(attribute: .EndDate)
        if !endDateString.isEmpty, let endDate = Date.dateFromRfc3339(string: endDateString) {
            return endDate
        }
        return nil
    }
    
    enum EditableSection: Int {
        case personalAttributes = 0
        case jobRole = 1
        case availabilityCalendar = 2
        case availabilityHours = 3
        case skills = 4
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let editableSection = EditableSection(rawValue: indexPath.section) else { return }
        guard let navCtrl = self.navigationController, let template = currentTemplate else { return }
        switch editableSection {
        case .personalAttributes:
            CustomNavigationHelper.sharedInstance.pushChooseAttributes(navCtrl, currentTemplate: template, attribute: .PersonalAttributes)
        case .jobRole:
            CustomNavigationHelper.sharedInstance.pushChooseAttributes(navCtrl, currentTemplate: template, attribute: .JobRole)
            
        case .availabilityCalendar:
            pushCalendar(navigationController: navCtrl)
            
        case .availabilityHours:
            pushDaysAndHours(navigationController: navCtrl)
            
        case .skills:
            CustomNavigationHelper.sharedInstance.pushChooseAttributes(navCtrl, currentTemplate: template, attribute: .EmploymentSkills)
        }
        coverLetterTableView.reloadData()
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let editableSection = EditableSection(rawValue: section) else { return 0 }
        switch editableSection
        {
        case .personalAttributes:
            return bigFooterSize
        case .jobRole:
            return smallFooterSize
        case .availabilityCalendar:
            return bigFooterSize
        case .availabilityHours:
            return bigFooterSize
        case .skills:
            return bigFooterSize
        }
    }
    
    func pushDaysAndHours(navigationController: UINavigationController) {
        let storyboard = UIStoryboard(name: "F4SDaysAndHours", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? F4SDaysAndHoursViewController else {
            return
        }
        vc.delegate = self
        if let model = applicationContext.availabilityPeriod?.daysAndHours {
            vc.model = model
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushCalendar(navigationController: UINavigationController) {
        let storyboard = UIStoryboard(name: "F4SCalendar", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? F4SCalendarContainerViewController else {
            return
        }
        if let firstDate = getStartDate(), let lastDate = getEndDate() {
            vc.setSelection(firstDate: firstDate, lastDate: lastDate)
        }
        
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var bigFooterView: UIView
        var smallFooterView: UIView

        EditFooterView.footerString = ""
        smallFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: smallFooterSize))
        
        guard let editableSection = EditableSection(rawValue: section) else { return smallFooterView }
        
        switch editableSection {
        case .personalAttributes:
            let string = NSLocalizedString("Choose up to \(self.getMaximumNumberOfChoicesForAttribute(attribute: .PersonalAttributes)) personal attributes to tell prospective employers about yourself.", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))

            return bigFooterView
        
        case .jobRole:
            return smallFooterView
        
        case .availabilityCalendar:
            let string = NSLocalizedString("Tell us when you are available", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))
            return bigFooterView
            
        case .availabilityHours:
            let string = NSLocalizedString("Choose your available working hours", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))
            return bigFooterView

        case .skills:
            // Choose up to three employment skills that you are hoping to acquire through this Work Experience Placement
            let string = NSLocalizedString("Choose up to \(self.getMaximumNumberOfChoicesForAttribute(attribute: .EmploymentSkills)) employment skills that you are hoping to acquire through this Work Experience Placement", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))
            return bigFooterView
        }
    }
}

// MARK: -user interraction
extension EditCoverLetterViewController {
    @IBAction func updateButton(_: AnyObject) {
        delegate.editCoverLetterDidUpdate(applicationContext: applicationContext)
        if let navCtrl = self.navigationController {
            navCtrl.popViewController(animated: true)
        }
    }

    @objc func popViewController(_: UIBarButtonItem) {
        if let navCtrl = self.navigationController {
            navCtrl.popViewController(animated: true)
        }
    }
}

// MARK: - setup appereance
extension EditCoverLetterViewController {
    func setupNavigationBar() {
        self.title = NSLocalizedString("Edit Letter", comment: "")
        styleNavigationController(titleColor: UIColor.black, backgroundColor: UIColor.white, tintColor: UIColor.black, useLightStatusBar: false)
    }

    func setupButtons() {
        updateButton.layer.cornerRadius = 10
        let buttonText = NSLocalizedString("Update Cover Letter", comment: "")
        let string = NSAttributedString(string: buttonText, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.mediumTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.white])
        updateButton.setAttributedTitle(string, for: .normal)
        updateButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        updateButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        updateButton.setTitleColor(UIColor.white, for: .normal)
        updateButton.setTitleColor(UIColor.white, for: .highlighted)
        updateButton.layer.masksToBounds = true
    }

    func setupAppereance() {
        setDateFormatter()
        setupButtons()
        setupNavigationBar()
        coverLetterTableView.backgroundColor = UIColor(netHex: Colors.lightGray)
        contentView.backgroundColor = UIColor(netHex: Colors.lightGray)
        setupTableView()
    }

    func setupTableView() {
        coverLetterTableView.delegate = self
        coverLetterTableView.dataSource = self
    }

    @objc func endDatePickerChanged(sender: UIDatePicker) {
        guard let endDate = sender.date.dateToStringRfc3339() else {
            return
        }
        self.saveDataForAttribute(data: endDate, attribute: .EndDate)
        coverLetterTableView.reloadRows(at: [NSIndexPath(row: 2, section: 2) as IndexPath], with: .none)
        setUpdateButtonState()
    }

    func setDateFormatter() {
        self.dateFormatter = DateFormatter()
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateFormat = "dd MMM yyyy"
    }

    func getValueForAttribute(attribute: ChooseAttributes) -> String {
        if let indexOfAttribute = self.selectedTemplateBlanks.index(where: { $0.name == attribute.rawValue }) {
            let templateBank = self.selectedTemplateBlanks[indexOfAttribute]
            switch attribute
            {
            case .PersonalAttributes:
                return templateBank.choices.count != 0 ? String(templateBank.choices.count) : ""
            case .JobRole:
                if let jobRole = templateBank.choices.first {
                    if let indexOfJobRole = self.currentTemplate?.blanks.index(where: { $0.name == attribute.rawValue }) {
                        if let indexOfJobRoleValue = self.currentTemplate?.blanks[indexOfJobRole].choices.index(where: { $0.uuid == jobRole.uuid }) {
                            if let value = self.currentTemplate?.blanks[indexOfJobRole].choices[indexOfJobRoleValue].value {
                                return value.capitalizingFirstLetter()
                            }
                        }
                    }
                }
                return ""
            case .StartDate:
                if let startDate = templateBank.choices.first {
                    return startDate.uuid
                }
                return ""
            case .EndDate:
                if let endDate = templateBank.choices.first {
                    return endDate.uuid
                }
                return ""
            default:
                // skills
                return templateBank.choices.count != 0 ? String(templateBank.choices.count) : ""
            }
        }
        return ""
    }

    func getMaximumNumberOfChoicesForAttribute(attribute: ChooseAttributes) -> Int {
        if let indexOfAttribute = self.currentTemplate?.blanks.index(where: { $0.name == attribute.rawValue }) {
            guard let templateBank = self.currentTemplate?.blanks[indexOfAttribute] else {
                return 0
            }
            switch attribute
            {
            case .PersonalAttributes:
                return templateBank.maxChoice
            case .EmploymentSkills:
                return templateBank.maxChoice
            default:
                return 0
            }
        }
        return 0
    }

    func saveDataForAttribute(data: String, attribute: ChooseAttributes) {
        if let indexOfAttribute = self.selectedTemplateBlanks.index(where: { $0.name == attribute.rawValue }) {
            switch attribute
            {
            case .StartDate:
                self.selectedTemplateBlanks[indexOfAttribute].choices = [Choice(uuid: data)]
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: self.selectedTemplateBlanks[indexOfAttribute].name, choiceList: [data])
                break
            case .EndDate:
                self.selectedTemplateBlanks[indexOfAttribute].choices = [Choice(uuid: data)]
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: self.selectedTemplateBlanks[indexOfAttribute].name, choiceList: [data])
                break
            default:
                break
            }
        } else {
            switch attribute
            {
            case .StartDate:
                let newBank = TemplateBlank(name: attribute.rawValue, choices: [Choice(uuid: data)])
                self.selectedTemplateBlanks.append(newBank)
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: attribute.rawValue, choiceList: [data])
                break
            case .EndDate:
                let newBank = TemplateBlank(name: attribute.rawValue, choices: [Choice(uuid: data)])
                self.selectedTemplateBlanks.append(newBank)
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: attribute.rawValue, choiceList: [data])
                break
            default:
                break
            }
        }
    }

    func setUpdateButtonState() {
        if self.selectedTemplateBlanks.count > 0 {
            // all data is set
            updateButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
            updateButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
            self.updateButton.isUserInteractionEnabled = true
        } else {
            self.updateButton.backgroundColor = UIColor(netHex: Colors.mediumGreen).withAlphaComponent(0.5)
            self.updateButton.isUserInteractionEnabled = false
        }
    }
}
