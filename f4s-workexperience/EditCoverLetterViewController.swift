//
//  CoverLetterViewController.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/22/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class EditCoverLetterViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverLetterTableView: UITableView!

    fileprivate var arrayTextEdit = [String]()
    fileprivate let coverLetterCellIdentifier = "CoverLetterIdentifier"
    fileprivate let datePickerCellIdentifier = "DatePickerCellIdentifier"
    fileprivate let bigFooterSize = CGFloat(56)
    fileprivate let smallFooterSize = CGFloat(21)
    fileprivate var numberOfRowsInSection2 = 4
    fileprivate let datePickerSize: CGFloat = 200

    var isVisibleStartDatePicker = false
    var isVisibleEndDatePicker = false
    let startDatePicker: UIDatePicker = UIDatePicker()
    let endDatePicker: UIDatePicker = UIDatePicker()

    var currentTemplate: TemplateEntity?
    var selectedTemplateChoices: [TemplateBlank] = []
    var dateFormatter: DateFormatter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppereance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.white)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.backBarButtonItem?.isEnabled = true

        coverLetterTableView.reloadData()
        self.selectedTemplateChoices = TemplateChoiceDBOperations.sharedInstance.getTemplateChoicesForCurrentUser()
        setUpdateButtonState()
    }
    
    func mergedBlanks(currentTemplate: TemplateEntity, selectedBlanks: [TemplateBlank]) -> [TemplateBlank] {
        var blanks = [TemplateBlank]()
        for selectedBlank in selectedBlanks {
            let currentTemplateBlanks = currentTemplate.blank // Resolves horrible name confusion
            guard let blankIndex = currentTemplateBlanks.index(where: { (otherBlank) -> Bool in
                otherBlank.name == selectedBlank.name
            }) else { continue }
            let currentTemplateBlank = currentTemplateBlanks[blankIndex]
            for choice in currentTemplateBlank.choices {
                
                
            }
            
        }
        return blanks
    }
    
    
}

// MARK: -UITableViewDelegate,UITableViewDataSource
extension EditCoverLetterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 4
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return numberOfRowsInSection2
        } else {
            return 1
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            if indexPath.row == 0 || indexPath.row == 2 {
                return CGFloat(44)
            }
            if indexPath.row == 1 {
                if isVisibleStartDatePicker {
                    return datePickerSize
                } else {
                    return CGFloat(0)
                }
            }
            if indexPath.row == 3 {
                if isVisibleEndDatePicker {
                    return datePickerSize
                } else {
                    return CGFloat(0)
                }
            }
        }

        return CGFloat(44)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: coverLetterCellIdentifier, for: indexPath) as? EditCoverLetterTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor.white
        cell.editTextLabel.attributedText = NSAttributedString(string: arrayTextEdit[indexPath.row], attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor.black])

        cell.arrowImageView.isHidden = false
        cell.arrowImageView.image = UIImage(named: "rightArrow")

        cell.editTextLabel.isHidden = false
        cell.editValueLabel.isHidden = false
        cell.arrowImageView.isHidden = false

        switch indexPath.section
        {
        case 0:

            cell.editTextLabel.text = arrayTextEdit[0]
            let attributeValue = self.getValueForAttribute(attribute: .PersonalAttributes)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = "\(attributeValue) chosen"
            }

        case 1:

            cell.editTextLabel.text = arrayTextEdit[1]
            let attributeValue = self.getValueForAttribute(attribute: .JobRole)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = attributeValue
            }

        case 2:
            cell.arrowImageView.isHidden = true
            if indexPath.row == 0 {
                cell.editTextLabel.text = arrayTextEdit[2]
                let startDateString = self.getValueForAttribute(attribute: .StartDate)
                if !startDateString.isEmpty, let startDate = Date.dateFromRfc3339(string: startDateString) {
                    cell.editValueLabel.text = self.dateFormatter?.string(from: startDate)
                } else {
                    cell.editValueLabel.text = ""
                }
            } else if indexPath.row == 1 {
                cell.editTextLabel.isHidden = true
                cell.editValueLabel.isHidden = true
                setStartDatePicker(cell: cell)
            } else if indexPath.row == 2 {
                cell.editTextLabel.text = arrayTextEdit[3]
                let endDateString = self.getValueForAttribute(attribute: .EndDate)
                if !endDateString.isEmpty, let endDate = Date.dateFromRfc3339(string: endDateString) {
                    cell.editValueLabel.text = self.dateFormatter?.string(from: endDate)
                } else {
                    cell.editValueLabel.text = ""
                }
            } else {
                cell.editTextLabel.isHidden = true
                cell.editValueLabel.isHidden = true
                setEndDatePicker(cell: cell)
            }
        case 3:

            cell.editTextLabel.text = arrayTextEdit[4]
            let attributeValue = self.getValueForAttribute(attribute: .EmploymentSkills)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = "\(attributeValue) chosen"
            }

        default:
            cell.editTextLabel.text = arrayTextEdit[0]
        }

        cell.editValueLabel.attributedText = NSAttributedString(string: cell.editValueLabel.text!, attributes: [NSAttributedStringKey.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor: UIColor(netHex: Colors.mediumGray)])

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if isVisibleStartDatePicker {
                isVisibleStartDatePicker = false
            } else if isVisibleEndDatePicker {
                isVisibleEndDatePicker = false
            } else {
                if let navCtrl = self.navigationController, let template = currentTemplate {
                    // go to personal attributes page
                    CustomNavigationHelper.sharedInstance.pushChooseAttributes(navCtrl, currentTemplate: template, attribute: .PersonalAttributes)
                }
            }
            coverLetterTableView.reloadData()
        case 1:
            if isVisibleStartDatePicker {
                isVisibleStartDatePicker = false
            } else if isVisibleEndDatePicker {
                isVisibleEndDatePicker = false
            } else {
                if let navCtrl = self.navigationController, let template = currentTemplate {
                    // go to job role page
                    CustomNavigationHelper.sharedInstance.pushChooseAttributes(navCtrl, currentTemplate: template, attribute: .JobRole)
                }
            }
            coverLetterTableView.reloadData()
        case 2:
            if indexPath.row == 0 {
                if isVisibleStartDatePicker {
                    isVisibleStartDatePicker = false
                } else if isVisibleEndDatePicker {
                    isVisibleEndDatePicker = false
                    isVisibleStartDatePicker = true
                } else {
                    isVisibleStartDatePicker = true
                }
            } else if indexPath.row == 2 {
                if isVisibleStartDatePicker {
                    isVisibleStartDatePicker = false
                    isVisibleEndDatePicker = true
                } else if isVisibleEndDatePicker {
                    isVisibleEndDatePicker = false
                } else {
                    isVisibleEndDatePicker = true
                }
            }
            coverLetterTableView.reloadData()

        case 3:
            if isVisibleStartDatePicker {
                isVisibleStartDatePicker = false
            } else if isVisibleEndDatePicker {
                isVisibleEndDatePicker = false
            } else {
                if let navCtrl = self.navigationController, let template = currentTemplate {
                    // go to employment skills
                    CustomNavigationHelper.sharedInstance.pushChooseAttributes(navCtrl, currentTemplate: template, attribute: .EmploymentSkills)
                }
            }
            coverLetterTableView.reloadData()

        default: break
        }
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section
        {
        case 0:
            return bigFooterSize
        case 1:
            return smallFooterSize
        case 2:
            return smallFooterSize
        case 3:
            return bigFooterSize
        default:
            return CGFloat(0)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var bigFooterView: UIView
        var smallFooterView: UIView

        EditFooterView.footerString = ""
        smallFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: smallFooterSize))

        switch section {
        case 0:
            let string = NSLocalizedString("Choose up to \(self.getMaximumNumberOfChoicesForAttribute(attribute: .PersonalAttributes)) personal attributes to tell prospective employers about yourself.", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))

            return bigFooterView

        case 3:
            let string = NSLocalizedString("Choose up to \(self.getMaximumNumberOfChoicesForAttribute(attribute: .EmploymentSkills)) employment skills to let prospective employers understand how others describe you.", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))

            return bigFooterView

        default:
            return smallFooterView
        }
    }
}

// MARK: -user interraction
extension EditCoverLetterViewController {
    @IBAction func updateButton(_: AnyObject) {
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
        self.navigationItem.title = NSLocalizedString("Edit Cover Letter", comment: "")
        var image = UIImage(named: "backArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(popViewController(_:)))
    }

    func setupTexts() {
        let personalAttributesTitle = NSLocalizedString("Personal attributes", comment: "")
        let jobRoleTitle = NSLocalizedString("Job role", comment: "")
        let availableFrom = NSLocalizedString("Available from", comment: "")
        let availableUntil = NSLocalizedString("Available until", comment: "")
        let employmentSkillsTitle = NSLocalizedString("Employment skills", comment: "")

        arrayTextEdit = [personalAttributesTitle, jobRoleTitle, availableFrom, availableUntil, employmentSkillsTitle]
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
        setupTexts()
        setupButtons()
        setupNavigationBar()

        coverLetterTableView.backgroundColor = UIColor(netHex: Colors.lightGray)
        contentView.backgroundColor = UIColor(netHex: Colors.lightGray)

        startDatePicker.addTarget(self, action: #selector(startDatePickerChanged(sender:)), for: .valueChanged)
        endDatePicker.datePickerMode = .date

        endDatePicker.addTarget(self, action: #selector(endDatePickerChanged(sender:)), for: .valueChanged)
        endDatePicker.datePickerMode = .date

        setupTableView()
    }

    func setupTableView() {
        coverLetterTableView.delegate = self
        coverLetterTableView.dataSource = self
    }

    func setStartDatePicker(cell: EditCoverLetterTableViewCell) {
        let now = Date()
        startDatePicker.frame.size.width = self.view.frame.size.width
        startDatePicker.frame.size.height = datePickerSize
        startDatePicker.backgroundColor = UIColor.white

        startDatePicker.datePickerMode = .date
        let earliestStartDate = WorkAvailabilityWindow.earliestStartDate(submission: now)
        startDatePicker.minimumDate = earliestStartDate

        let startDate = self.getValueForAttribute(attribute: .StartDate)
        if !startDate.isEmpty, let startD = Date.dateFromRfc3339(string: startDate) {
            startDatePicker.date = startD > earliestStartDate ? startD : earliestStartDate
        }
        cell.contentView.addSubview(startDatePicker)
        startDatePickerChanged(sender: startDatePicker)
    }
    
    @objc func startDatePickerChanged(sender: UIDatePicker) {
        guard let startDate = sender.date.dateToStringRfc3339() else {
            return
        }
        self.saveDataForAttribute(data: startDate, attribute: .StartDate)
        let earliestEndDate = WorkAvailabilityWindow.earliestEndDate(start: sender.date, submission: Date())
        endDatePicker.minimumDate = earliestEndDate

        let endDateString = self.getValueForAttribute(attribute: .EndDate)
        if !endDateString.isEmpty, let endDate = Date.dateFromRfc3339(string: endDateString) {
            if endDate < earliestEndDate {
                self.saveDataForAttribute(data: earliestEndDate.dateToStringRfc3339()!, attribute: .EndDate)
                coverLetterTableView.reloadRows(at: [NSIndexPath(row: 2, section: 2) as IndexPath], with: .none)
            }
        }

        coverLetterTableView.reloadRows(at: [NSIndexPath(row: 0, section: 2) as IndexPath], with: .none)
        setUpdateButtonState()
    }

    func setEndDatePicker(cell: EditCoverLetterTableViewCell) {
        endDatePicker.frame.size.width = self.view.frame.size.width
        endDatePicker.frame.size.height = datePickerSize
        endDatePicker.backgroundColor = UIColor.white
        let now = Date()
        let startDateString = self.getValueForAttribute(attribute: .StartDate)
        var startDate: Date! = nil
        if !startDateString.isEmpty {
            startDate = Date.dateFromRfc3339(string: startDateString)!
        }
        if startDate == nil {
            startDate = WorkAvailabilityWindow.earliestStartDate(submission: now)
        }
        let earliestEndDate = WorkAvailabilityWindow.earliestEndDate(start: startDate, submission: now)
        endDatePicker.minimumDate = earliestEndDate
    
        let endDateString = self.getValueForAttribute(attribute: .EndDate)
        if !endDateString.isEmpty, let endDate = Date.dateFromRfc3339(string: endDateString) {
            endDatePicker.date = endDate > earliestEndDate ? endDate : earliestEndDate
        }

        endDatePicker.datePickerMode = .date
        cell.contentView.addSubview(endDatePicker)
        endDatePickerChanged(sender: endDatePicker)
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
        if let indexOfAttribute = self.selectedTemplateChoices.index(where: { $0.name == attribute.rawValue }) {
            let templateBank = self.selectedTemplateChoices[indexOfAttribute]
            switch attribute
            {
            case .PersonalAttributes:
                return templateBank.choices.count != 0 ? String(templateBank.choices.count) : ""
            case .JobRole:
                if let jobRole = templateBank.choices.first {
                    if let indexOfJobRole = self.currentTemplate?.blank.index(where: { $0.name == attribute.rawValue }) {
                        if let indexOfJobRoleValue = self.currentTemplate?.blank[indexOfJobRole].choices.index(where: { $0.uuid == jobRole.uuid }) {
                            if let value = self.currentTemplate?.blank[indexOfJobRole].choices[indexOfJobRoleValue].value {
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
        if let indexOfAttribute = self.currentTemplate?.blank.index(where: { $0.name == attribute.rawValue }) {
            guard let templateBank = self.currentTemplate?.blank[indexOfAttribute] else {
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
        if let indexOfAttribute = self.selectedTemplateChoices.index(where: { $0.name == attribute.rawValue }) {
            switch attribute
            {
            case .StartDate:
                self.selectedTemplateChoices[indexOfAttribute].choices = [Choice(uuid: data)]
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: self.selectedTemplateChoices[indexOfAttribute].name, choiceList: [data])
                break
            case .EndDate:
                self.selectedTemplateChoices[indexOfAttribute].choices = [Choice(uuid: data)]
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: self.selectedTemplateChoices[indexOfAttribute].name, choiceList: [data])
                break
            default:
                break
            }
        } else {
            switch attribute
            {
            case .StartDate:
                let newBank = TemplateBlank(name: attribute.rawValue, choices: [Choice(uuid: data)])
                self.selectedTemplateChoices.append(newBank)
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: attribute.rawValue, choiceList: [data])
                break
            case .EndDate:
                let newBank = TemplateBlank(name: attribute.rawValue, choices: [Choice(uuid: data)])
                self.selectedTemplateChoices.append(newBank)
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: attribute.rawValue, choiceList: [data])
                break
            default:
                break
            }
        }
    }

    func setUpdateButtonState() {
        if self.selectedTemplateChoices.count > 0 {
            // all data is setted
            updateButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
            updateButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
            self.updateButton.isUserInteractionEnabled = true
        } else {
            self.updateButton.backgroundColor = UIColor(netHex: Colors.mediumGreen).withAlphaComponent(0.5)
            self.updateButton.isUserInteractionEnabled = false
        }
    }
}
