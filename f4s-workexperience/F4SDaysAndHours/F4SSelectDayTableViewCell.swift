//
//  F4SSelectDayTableViewCell.swift
//  HoursPicker2
//
//  Created by Keith Dev on 27/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

public protocol F4SSelectDayTableViewCellDelegate {
    func selectionButtonWasTapped(_ cell: F4SSelectDayTableViewCell)
}

public class F4SSelectDayTableViewCell: UITableViewCell {

    @IBOutlet weak var tickImage: UIImageView!
    
    var delegate: F4SSelectDayTableViewCellDelegate?
    var tapRecognizer: UITapGestureRecognizer!
    
    public var dayHourSelection: F4SDayAndHourSelection! {
        didSet {
            dayNameLabel.text = dayHourSelection.dayOfWeek.longSymbol
            tickImage.image = dayHourSelection.dayIsSelected ? #imageLiteral(resourceName: "roundedCheckboxPink") : #imageLiteral(resourceName: "roundedCheckboxGREY")
            hoursDropdownLabel.text = dayHourSelection.hoursType.description
            enable(dayHourSelection.dayIsSelected)
        }
    }
    
    @objc func didTapSelectionTick() {
        delegate?.selectionButtonWasTapped(self)
    }

    
    @IBOutlet weak var dayNameLabel: UILabel!
    
    @IBOutlet weak var hoursDropdownLabel: UILabel!
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInitialization()
    }
    
    public func commonInitialization() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSelectionTick))
        tickImage.isUserInteractionEnabled = true
        tickImage.addGestureRecognizer(tapRecognizer)
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func enable(_ enable: Bool) {
        if enable {
            dayNameLabel.textColor = UIColor.black
            hoursDropdownLabel.textColor = UIColor.black
        } else {
            dayNameLabel.textColor = UIColor.lightGray
            hoursDropdownLabel.textColor = UIColor.lightGray
        }
    }

}
