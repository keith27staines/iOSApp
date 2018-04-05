//
//  F4SDaysAndHoursViewController.swift
//  HoursPicker2
//
//  Created by Keith Dev on 27/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDaysAndHoursViewController: UIViewController {
    @IBOutlet weak var headerIcon: UIImageView!
    
    var model: F4SDaysAndHoursModel!
    let weekDayButtonTitle = "WEEKDAYS"
    let weekendButtonTitle = "WEEKENDS"
    
    @IBOutlet weak var pageHeaderView: F4SPageHeaderView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var weekdaysButton: UIButton!
    
    @IBOutlet weak var weekendsButton: UIButton!
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var footerLabel: UILabel!
    
    var splashColor = UIColor(red: 72/255, green: 38/255, blue: 127/255, alpha: 1.0)
    
    lazy var hoursPicker: F4SHoursPickerViewController? = {
        guard let pickerVC = self.storyboard?.instantiateViewController(withIdentifier: "HoursPicker") as? F4SHoursPickerViewController else {
            return nil
        }
        guard let pickerView = pickerVC.view else {
            return nil
        }
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.isHidden = true
        self.view.addSubview(pickerView)
        self.addChildViewController(pickerVC)
        pickerVC.delegate = self
        return pickerVC
    }()
    
    var pickerView: UIView? {
        return hoursPicker?.view
    }
    
    var maskView: UIView?
    
    lazy var infoController: F4SDisplayInformationViewController = {
        let storyboard = UIStoryboard(name: "F4SDisplayInformationViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! F4SDisplayInformationViewController
        vc.delegate = self
        vc.type = F4SDisplayInformationType.daysAndHoursViewController
        return vc
    }()
    
    var pickerCenterXConstraint: NSLayoutConstraint?
    var pickerCenterYConstraint: NSLayoutConstraint?
    
    lazy var pickerHeightConstraint: NSLayoutConstraint? = {
        let constraint = hoursPicker?.view.heightAnchor.constraint(equalToConstant: 40)
        constraint?.isActive = true
        return constraint
    }()
    
    var pickerWidthConstraint: NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = (model != nil) ? model : F4SDaysAndHoursModel()
        applyStype()
        configureControls()
        reloadDataViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationController(titleColor: UIColor.white, backgroundColor: splashColor, tintColor: UIColor.white, useLightStatusBar: true)
    }
}

// MARK:-  Display and manage hours picker
extension F4SDaysAndHoursViewController {
    func displayHoursPicker(indexPath: IndexPath) {
        showPickerView(indexPath: indexPath)
    }
}

// MARK:- Picker view handling
extension F4SDaysAndHoursViewController {
    func showPickerView(indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? F4SSelectDayTableViewCell else {
            return
        }
        guard let label = cell.hoursDropdownLabel else {
            return
        }
        guard let pickerView = pickerView else {
            return
        }
        tiePickerToLabel(label: label)
        if pickerView.isHidden {
            pickerView.frame = self.view.convert(label.frame, from: cell)
            pickerView.isHidden = false
            pickerView.alpha = 0.0
        }
        
        pickerHeightConstraint?.constant = 120
        hoursPicker?.selectedHoursType = model.allDays[indexPath.row].hoursType
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            pickerView.alpha = 1.0
            self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hidePickerView() {
        guard pickerView?.isHidden == false else { return }
        pickerHeightConstraint?.constant = 40
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pickerView?.alpha = 0.0
            self?.view.layoutIfNeeded()
        }) { [weak self] (completed) in
            self?.pickerView?.isHidden = true
        }
    }
    
    func removeConstraintsFromPicker() {
        guard let pickerView = hoursPicker?.view else {
            return
        }
        if let constraint = pickerCenterXConstraint {
            constraint.isActive = false
            pickerView.removeConstraint(constraint)
        }
        if let constraint = pickerCenterYConstraint {
            constraint.isActive = false
            pickerView.removeConstraint(constraint)
        }
        if let constraint = pickerWidthConstraint {
            constraint.isActive = false
            pickerView.removeConstraint(constraint)
        }
    }
    
    func tiePickerToLabel(label: UILabel) {
        removeConstraintsFromPicker()
        guard let view = pickerView else { return }
        pickerCenterXConstraint = view.centerXAnchor.constraint(equalTo: label.centerXAnchor)
        pickerCenterYConstraint = view.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        pickerWidthConstraint = view.widthAnchor.constraint(equalTo: label.widthAnchor)
        pickerCenterXConstraint?.isActive = true
        pickerCenterYConstraint?.isActive = true
        pickerWidthConstraint?.isActive = true
        pickerHeightConstraint?.isActive = true
    }
}

// MARK:- Data handling
extension F4SDaysAndHoursViewController {
    func reloadDataViews() {
        tableView.reloadData()
        let minus = "− "
        let plus  = "+ "
        let weekDaysSign = areWeekDaysFullySelected() ? minus : plus
        let weekTitle = weekDaysSign + weekDayButtonTitle
        let weekEndSign = areWeekendsFullySelected() ? minus : plus
        let weekendTitle = weekEndSign + weekendButtonTitle
        weekdaysButton.setTitle(weekTitle, for: .normal)
        weekendsButton.setTitle(weekendTitle, for: .normal)
        styleGhostButton(button: weekdaysButton, solid: weekDaysSign == minus)
        styleGhostButton(button: weekendsButton, solid: weekEndSign == minus)
    }
}

// MARK:- Configure controls
extension F4SDaysAndHoursViewController {
    func configureControls() {
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        let item = UIBarButtonItem()
        item.title = "Info"
        item.target = self
        item.action = #selector(mainInfoTapped)
        item.style = .plain
        self.navigationItem.rightBarButtonItem = item
    }
}

// MARK:- Styling
extension F4SDaysAndHoursViewController {
    func applyStype() {
        pageHeaderView.splashColor = splashColor
    }
    
    func styleGhostButton(button: UIButton, solid: Bool) {
        button.layer.borderColor = splashColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        let titleColor = solid ? UIColor.white : splashColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.backgroundColor = solid ? splashColor.cgColor : UIColor.white.cgColor
    }
    

}

extension UIViewController {
    /// Style the navigation bar
    /// - parameter titleColor: The color for the title text
    /// - Parameter splashColor: The background color
    /// - Parameter tintColor: The tint color for the title and buttons
    /// - Parameter useLightStatusBar: a hint to the system to use light status bar content
    func styleNavigationController(titleColor: UIColor, backgroundColor: UIColor, tintColor: UIColor, useLightStatusBar: Bool) {
        guard let navigationController = self.navigationController else {
            return
        }
        navigationController.navigationBar.tintColor = tintColor
        navigationController.navigationBar.barTintColor = backgroundColor
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:titleColor]
        navigationController.navigationBar.barStyle =  useLightStatusBar ? .black : .default
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.isNavigationBarHidden = false
    }
}

extension F4SDaysAndHoursViewController : F4SHoursPickerDelegate {
    func hoursPicker(_ picker: F4SHoursPickerViewController, hoursType: F4SHoursType) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        model.setHoursForDay(hoursType: hoursType, day: model.allDays[indexPath.row])
        removeConstraintsFromPicker()
        tableView.reloadRows(at: [indexPath], with: .none)
        let cell = tableView.cellForRow(at: indexPath) as! F4SSelectDayTableViewCell
        tiePickerToLabel(label: cell.hoursDropdownLabel)
        hidePickerView()
    }
}

// MARK:- Handle info view display
extension F4SDaysAndHoursViewController: F4SDisplayInformationViewControllerDelegate {
    
    func dismissDisplayInformation() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
             self?.infoController.view?.alpha = 0.0
        }) { [weak self] (success) in
            self?.infoController.view?.removeFromSuperview()
            self?.maskView?.removeFromSuperview()
            self?.maskView = nil
        }
    }
    
    @objc func mainInfoTapped() {
        guard maskView == nil else { return }
        hidePickerView()
        let mainView = self.view!
        let infoView = infoController.view!
        infoView.layer.borderColor = UIColor.darkGray.cgColor
        infoView.layer.borderWidth = 1
        infoView.layer.cornerRadius = 8
        infoView.clipsToBounds = true
        maskView = UIView(frame: mainView.frame)
        maskView?.translatesAutoresizingMaskIntoConstraints = false
        maskView?.isUserInteractionEnabled = true
        maskView?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        mainView.addSubview(maskView!)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(infoView)
        maskView?.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        maskView?.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        maskView?.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        maskView?.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        if !self.childViewControllers.contains(infoController) {
            self.addChildViewController(infoController)
        }
        infoView.alpha = 0.0
        infoView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        infoView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        UIView.animate(withDuration: 0.2) {
            infoView.alpha = 1.0
            mainView.layoutIfNeeded()
        }
    }
}

// MARK:- Handle user interactions
extension F4SDaysAndHoursViewController {
    
    @IBAction func clearSelections(sender: UIButton) {
        hidePickerView()
        model.selectDays(value: false, include: { (day) -> Bool in
            return true
        })
        reloadDataViews()
    }
    
    @IBAction func toggleWeekDays(sender: UIButton) {
        hidePickerView()
        let value = areWeekDaysFullySelected() ? false : true
        model.selectDays(value: value, include: { (day) -> Bool in
            return !day.dayOfWeek.isWeekend
        })
        reloadDataViews()
    }
    
    @IBAction func toggleWeekends(sender: UIButton) {
        hidePickerView()
        let value = areWeekendsFullySelected() ? false : true
        model.selectDays(value: value, include: { (day) -> Bool in
            return day.dayOfWeek.isWeekend
        })
        reloadDataViews()
    }
}

extension F4SDaysAndHoursViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.allDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "F4SSelectDayTableViewCell") as! F4SSelectDayTableViewCell
        cell.dayHourSelection = model.allDays[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let isAvailableForSelection = model.allDays[indexPath.row].dayIsSelected
        return isAvailableForSelection ? indexPath :  nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayHoursPicker(indexPath: indexPath)
    }
}

extension F4SDaysAndHoursViewController : F4SSelectDayTableViewCellDelegate {
    
    func selectionButtonWasTapped(_ cell: F4SSelectDayTableViewCell) {
        hidePickerView()
        let selected = !cell.dayHourSelection.dayIsSelected
        model.selectDays(value: selected) { (day) -> Bool in
            day.dayOfWeek == cell.dayHourSelection.dayOfWeek
        }
        reloadDataViews()
    }
    
    func areWeekDaysFullySelected() -> Bool {
        for day in model.allDays {
            if !day.dayOfWeek.isWeekend && !day.dayIsSelected { return false }
        }
        return true
    }
    
    func areWeekendsFullySelected() -> Bool {
        for day in model.allDays {
            if day.dayOfWeek.isWeekend && !day.dayIsSelected { return false }
        }
        return true
    }
}
