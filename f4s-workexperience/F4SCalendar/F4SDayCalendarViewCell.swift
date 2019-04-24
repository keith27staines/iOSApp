//
//  F4SDayCalendarViewCell.swift
//  HoursPicker2
//
//  Created by Keith Dev on 15/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

extension Skin {
    func calendarCellBackgroundColor(type: F4SCalendarDaySelectionType) -> UIColor {
        switch type {
        case .intermonthUnselected:
            return midGrey
        case .intermonthSelected:
            return self.primaryButtonSkin.backgroundColor.disabledColor.uiColor
        case .unselectable:
            return pinkishGrey
        case .unselected:
            return pinkishGrey
        case .selected:
            return self.primaryButtonSkin.backgroundColor.uiColor
        case .todayUnselected:
            return self.navigationBarSkin.barTintColor.uiColor
        case .todaySelected:
            return self.primaryButtonSkin.backgroundColor.uiColor
        }
    }
    
    func calendarCellTextColor(type: F4SCalendarDaySelectionType) -> UIColor {
        switch type {
        case .intermonthUnselected:
            return textGrey
        case .intermonthSelected:
            return UIColor.white
        case .unselectable:
            return textGrey
        case .unselected:
            return textLightGrey
        case .selected:
            return UIColor.white
        case .todayUnselected:
            return UIColor.white
        case .todaySelected:
            return UIColor.white
        }
    }
}

public class F4SCalendarMonthViewDayCell: UICollectionViewCell {
    static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    public var selectionBarColor: UIColor = UIColor(displayP3Red: 0.7, green: 1.0, blue: 0.5, alpha: 1.0)
    public var selectionBarColorOffMonth = UIColor(displayP3Red: 0.9, green: 1.0, blue: 0.95, alpha: 1.0)
    
    public var deselectedColor: UIColor = UIColor(white: 0.9, alpha: 1.0)
    public var deselectedColorOffMonth : UIColor = UIColor(white: 0.95, alpha: 1.0)
    
    var notifyDidTap: ((F4SCalendarMonthViewDayCell) -> Void)?
    
    var isOnMonth: Bool {
        return (day != nil && calendarMonth.contains(day: day))
    }
    
    var usePrimaryStyling: Bool = true
    
    public var selectionState: F4SExtendibleSelectionState = .none {
        didSet {
            if usePrimaryStyling {
                applyPrimaryStyling(day: day)
                return
            }
            let selectedColor = isOnMonth ? selectionBarColor : selectionBarColorOffMonth
            terminalView.backgroundColor = selectedColor
            terminalView.layer.borderColor = isOnMonth ? UIColor.darkGray.cgColor : UIColor.lightGray.cgColor
            let backgroundColor = self.backgroundColor
            switch selectionState {
            case .none:
                terminalView.backgroundColor = isOnMonth ? deselectedColor : deselectedColorOffMonth
                extendLeftView.backgroundColor = backgroundColor
                extendRightView.backgroundColor = backgroundColor
            case .terminal:
                extendLeftView.backgroundColor = backgroundColor
                extendRightView.backgroundColor = backgroundColor
            case .periodStart:
                extendLeftView.backgroundColor = backgroundColor
                extendRightView.backgroundColor = selectedColor
            case .periodEnd:
                extendLeftView.backgroundColor = selectedColor
                extendRightView.backgroundColor = backgroundColor
            case .midPeriod:
                extendLeftView.backgroundColor = selectedColor
                extendRightView.backgroundColor = selectedColor
            }
        }
    }
    
    var numberFormatter: NumberFormatter {
        return F4SCalendarMonthViewDayCell.numberFormatter
    }
    
    func configure(day: F4SCalendarDay, calendarMonth: F4SCalendarMonth) {
        self.calendarMonth = calendarMonth
        self.day = day
    }
    
    public private (set) var day: F4SCalendarDay! {
        didSet {
            let number = NSNumber(value: day.dayOfMonth)
            dateLabel.text = numberFormatter.string(from: number)
            if usePrimaryStyling {
                applyPrimaryStyling(day: day)
            } else {
                applySecondaryStyling(day: day)
            }
        }
    }
    
    func applyPrimaryStyling(day: F4SCalendarDay?) {
        guard let day = day else { return }
        terminalView.backgroundColor = UIColor.clear
        extendLeftView.alpha = 0.0
        extendRightView.alpha = 0.0
        if !isOnMonth {
            if selectionState == .none {
                backgroundColor = skin?.calendarCellBackgroundColor(type: .intermonthUnselected)
                dateLabel.textColor = skin?.calendarCellTextColor(type: .intermonthUnselected)
            } else {
                backgroundColor = skin?.calendarCellBackgroundColor(type: .intermonthSelected)
                dateLabel.textColor = skin?.calendarCellTextColor(type: .intermonthSelected)
            }
            return
        }
        if day.isToday {
            if selectionState == .none {
                backgroundColor = skin?.calendarCellBackgroundColor(type: .todayUnselected)
                dateLabel.textColor = skin?.calendarCellTextColor(type: .todayUnselected)
            } else {
                backgroundColor = skin?.calendarCellBackgroundColor(type: .todaySelected)
                dateLabel.textColor = skin?.calendarCellTextColor(type: .todaySelected)
            }
            return
        }
        if day.isInPast {
            if selectionState == .none {
                backgroundColor = skin?.calendarCellBackgroundColor(type: .unselectable)
                dateLabel.textColor = skin?.calendarCellTextColor(type: .unselectable)
            }
            return
        }
        if selectionState == .none {
            backgroundColor = skin?.calendarCellBackgroundColor(type: .unselected)
            dateLabel.textColor = skin?.calendarCellTextColor(type: .unselected)
        } else {
            backgroundColor = skin?.calendarCellBackgroundColor(type: .selected)
            dateLabel.textColor = skin?.calendarCellTextColor(type: .selected)
        }
        return
    }
    
    
    func applySecondaryStyling(day: F4SCalendarDay) {
        if calendarMonth.contains(day: day) {
            dateLabel.textColor = UIColor.black
        } else {
            dateLabel.textColor = UIColor.lightGray
        }
    }
    
    private var calendarMonth: F4SCalendarMonth!
    
    let dateLabel: UILabel
    let terminalView: UIView
    let extendLeftView: UIView
    let extendRightView: UIView
    
    public override init(frame: CGRect) {
        dateLabel = UILabel()
        terminalView = UIView()
        extendLeftView = UIView()
        extendRightView = UIView()
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        dateLabel = UILabel()
        terminalView = UIView()
        extendLeftView = UIView()
        extendRightView = UIView()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        addSubviews()
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func addSubviews() {
        let tapRecognizerRight = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapRecognizerRight)
        addExtendLeftAndRightViews()
        addTerminalView()
        selectionState = .none
    }
    
    func addExtendLeftAndRightViews() {
        extendLeftView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(extendLeftView)
        
        // The 0.5 in the constraint constant immediately below is to allow for a glitch where a small gap
        // appears, splitting the connector between two selected cells
        leftAnchor.constraint(equalTo: extendLeftView.leftAnchor, constant: 0.5).isActive = true
        
        centerXAnchor.constraint(equalTo: extendLeftView.rightAnchor).isActive = true
        centerYAnchor.constraint(equalTo: extendLeftView.centerYAnchor).isActive = true
        extendLeftView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        let tapRecognizerLeft = UITapGestureRecognizer(target: self, action: #selector(didTap))
        extendLeftView.addGestureRecognizer(tapRecognizerLeft)
        
        extendRightView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(extendRightView)
        rightAnchor.constraint(equalTo: extendRightView.rightAnchor).isActive = true
        centerXAnchor.constraint(equalTo: extendRightView.leftAnchor).isActive = true
        centerYAnchor.constraint(equalTo: extendRightView.centerYAnchor).isActive = true
        extendRightView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        let tapRecognizerRight = UITapGestureRecognizer(target: self, action: #selector(didTap))
        extendRightView.addGestureRecognizer(tapRecognizerRight)
    }
    
    func addTerminalView() {
        terminalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(terminalView)
        addLabel()
        centerXAnchor.constraint(equalTo: terminalView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: terminalView.centerYAnchor).isActive = true
        terminalView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        terminalView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        terminalView.layer.cornerRadius = 20
        terminalView.layer.borderWidth = 0
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        terminalView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTap() {
        notifyDidTap?(self)
    }
    
    func addLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        terminalView.addSubview(dateLabel)
        terminalView.centerXAnchor.constraint(equalTo: dateLabel.centerXAnchor).isActive = true
        terminalView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalTo: dateLabel.widthAnchor, multiplier: 1.0)
        terminalView.leftAnchor.constraint(lessThanOrEqualTo: dateLabel.leftAnchor).isActive = true
        terminalView.topAnchor.constraint(lessThanOrEqualTo: dateLabel.topAnchor).isActive = true
        dateLabel.textAlignment = .center
        dateLabel.layer.cornerRadius = 8
        dateLabel.font = UIFont.boldSystemFont(ofSize: 18)
    }

    
}
