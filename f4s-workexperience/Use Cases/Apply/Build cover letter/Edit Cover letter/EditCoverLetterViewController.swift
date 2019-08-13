//
//  CoverLetterViewController.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/22/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderApplyUseCase
import WorkfinderUI

protocol EditCoverLetterViewControllerCoordinatorProtocol {
    func chooseValuesForTemplateBlank(name: TemplateBlankName, inTemplate: F4STemplate)
    func editCoverLetterViewControllerDidCancel()
    func editCoverLetterViewControllerDidFinish(_ viewController: EditCoverLetterViewController)
}

class EditCoverLetterViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverLetterTableView: UITableView!

    fileprivate let coverLetterCellIdentifier = "CoverLetterIdentifier"
    fileprivate let bigFooterSize = CGFloat(56)
    fileprivate let smallFooterSize = CGFloat(21)
    fileprivate var numberOfRowsInSection2 = 2
    var dateFormatter: DateFormatter?
    var availabilityPeriodJson: F4SAvailabilityPeriodJson = F4SAvailabilityPeriodJson()
    var coordinator: EditCoverLetterViewControllerCoordinatorProtocol?
    
    var blanksModel: ApplicationLetterTemplateBlanksModelProtocol? {
        didSet {
            updateFromModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppereance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
        updateFromModel()
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
        coverLetterTableView.reloadData()
        applyStyle()
        setUpdateButtonState()
    }
    
    func applyStyle() {
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: updateButton)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateFromModel() {
        guard let _ = blanksModel, let coverLetterTableView = coverLetterTableView else { return }
        coverLetterTableView.reloadData()
    }
}

extension EditCoverLetterViewController : F4SDaysAndHoursViewControllerDelegate {
    func didUpdateDaysAndHours(model: F4SDaysAndHoursModel) {
        var availabilityPeriod = F4SAvailabilityPeriod(availabilityPeriodJson: self.availabilityPeriodJson)
        availabilityPeriod.daysAndHours = model
        let availabilityPeriodJson = availabilityPeriod.makeAvailabilityPeriodJson()
        self.availabilityPeriodJson = availabilityPeriodJson
        coverLetterTableView.reloadData()
    }
}

extension EditCoverLetterViewController :  F4SCalendarCollectionViewControllerDelegate {
    func calendarDidChangeRange(_ calendar: F4SCalendarCollectionViewController, firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        updateAvailabilityPeriod(firstDay: firstDay, lastDay: lastDay)
        blanksModel?.updateBlanksFor(firstDay: firstDay, lastDay: lastDay)
        updateFromModel()
        setUpdateButtonState()
    }
    
    func updateAvailabilityPeriod(firstDay: F4SCalendarDay?, lastDay: F4SCalendarDay?) {
        var availabilityPeriod = F4SAvailabilityPeriod(availabilityPeriodJson: self.availabilityPeriodJson)
        availabilityPeriod.firstDay = firstDay
        availabilityPeriod.lastDay = lastDay
        self.availabilityPeriodJson = availabilityPeriod.makeAvailabilityPeriodJson()
    }
    
    func setStartOrEndDateChoices(value: String, blankName: TemplateBlankName) {
        guard blankName == .startDate || blankName == .endDate else { return }
        let blanksModel = self.blanksModel!
        var blank = blanksModel.populatedBlankWithName(blankName) ?? F4STemplateBlank(name: blankName.rawValue, choices: [F4SChoice(uuid: value)])
        
        blank.choices = [F4SChoice(uuid: value)]
        try! blanksModel.addOrReplacePopulatedBlank(blank)
        
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
            let attributeValue = getValueForTemplateBlank(name: .personalAttributes)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = "\(attributeValue) chosen"
            }

        case .jobRole:

            cell.editTextLabel.text = NSLocalizedString("Job role", comment: "")
            let attributeValue = getValueForTemplateBlank(name: .jobRole)
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
            let dayTimeInfo = availabilityPeriodJson.day_time_info
            if dayTimeInfo == nil || dayTimeInfo!.isEmpty {
                cell.editValueLabel.text = "(optional) Choose"
            } else {
                cell.editValueLabel.text = "Selected"
            }

        case .skills:

            cell.editTextLabel.text = NSLocalizedString("Employment skills", comment: "")
            let attributeValue = self.getValueForTemplateBlank(name: .employmentSkills)
            if attributeValue.isEmpty {
                cell.editValueLabel.isHidden = true
            } else {
                cell.editValueLabel.isHidden = false
                cell.editValueLabel.text = "\(attributeValue) chosen"
            }
        }

        cell.editValueLabel.attributedText = NSAttributedString(string: cell.editValueLabel.text!, attributes: [NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.largeTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.mediumGray)])

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
        let startDateString = self.getValueForTemplateBlank(name: .startDate)
        if !startDateString.isEmpty, let startDate = Date.dateFromRfc3339(string: startDateString) {
            return startDate
        }
        return nil
    }
    
    func getEndDate() -> Date? {
        let endDateString = self.getValueForTemplateBlank(name: .endDate)
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
        guard let navCtrl = self.navigationController, let template = blanksModel?.template else { return }
        switch editableSection {
        case .personalAttributes:
            coordinator?.chooseValuesForTemplateBlank(name: .personalAttributes, inTemplate: template)
            
        case .jobRole:
            coordinator?.chooseValuesForTemplateBlank(name: .jobRole, inTemplate: template)
            
        case .availabilityCalendar:
            pushCalendar(navigationController: navCtrl)
            
        case .availabilityHours:
            pushDaysAndHours(navigationController: navCtrl)
            
        case .skills:
            coordinator?.chooseValuesForTemplateBlank(name: .employmentSkills, inTemplate: template)
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
        let availabilityPeriod = F4SAvailabilityPeriod(availabilityPeriodJson: self.availabilityPeriodJson)
        vc.model = availabilityPeriod.daysAndHours
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
            let string = NSLocalizedString("Choose up to \(self.getMaximumNumberOfChoicesFor(blankName: .personalAttributes)) personal attributes to tell prospective employers about yourself.", comment: "")
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
            let string = NSLocalizedString("Choose up to \(self.getMaximumNumberOfChoicesFor(blankName: .employmentSkills)) employment skills that you are hoping to acquire through this Work Experience Placement", comment: "")
            EditFooterView.footerString = string
            bigFooterView = EditFooterView(frame: CGRect(x: 0, y: 0, width: self.coverLetterTableView.frame.size.width, height: bigFooterSize))
            return bigFooterView
        }
    }
}

// MARK:- user interraction
extension EditCoverLetterViewController {
    @IBAction func updateButton(_: AnyObject) {
        coordinator?.editCoverLetterViewControllerDidFinish(self)
    }

    @objc func cancel() {
        coordinator?.editCoverLetterViewControllerDidCancel()
    }
}

// MARK: - setup appereance
extension EditCoverLetterViewController {
    func setupNavigationBar() {
        self.title = NSLocalizedString("Edit Letter", comment: "")
        let image = UIImage(named: "backArrow")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel))
        styleNavigationController()
    }

    func setupButtons() {
        let buttonText = NSLocalizedString("Update Cover Letter", comment: "")
        updateButton.setTitle(buttonText, for: .normal)
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: updateButton)
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

    func setDateFormatter() {
        self.dateFormatter = DateFormatter()
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateFormat = "dd MMM yyyy"
    }

    func getValueForTemplateBlank(name: TemplateBlankName) -> String {
        guard let choices = blanksModel?.populatedBlankWithName(name)?.choices else { return "" }
        switch name {
        case .personalAttributes:
            return choices.count != 0 ? String(choices.count) : ""
        case .jobRole:
            return choices.first?.value.capitalizingFirstLetter() ?? ""
        case .startDate:
            guard let uuid = choices.first?.uuid else { return "" }
            return uuid
        case .endDate:
            guard let uuid = choices.first?.uuid else { return "" }
            return uuid
        case .employmentSkills:
            return choices.count != 0 ? String(choices.count) : ""
        }
    }

    func getMaximumNumberOfChoicesFor(blankName: TemplateBlankName) -> Int {
        return blanksModel?.templateBlankWithName(blankName)?.maxChoices ?? 0
    }

    func setUpdateButtonState() {
        updateButton.isEnabled = true
    }
}
