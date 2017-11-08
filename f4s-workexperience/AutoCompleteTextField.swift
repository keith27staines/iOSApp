//
//  AutoCompleteTextField.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 23/08/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import UIKit

open class AutoCompleteTextField: UITextField {

    open override func draw(_ rect: CGRect) {
        if shouldDrawUnderline {
            let startingPoint = CGPoint(x: rect.minX, y: rect.maxY)
            let endingPoint = CGPoint(x: rect.maxX, y: rect.maxY)
            let strokeColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)

            let path = UIBezierPath()

            path.move(to: startingPoint)
            path.addLine(to: endingPoint)
            path.lineWidth = 1.0
            strokeColor.setStroke()

            path.stroke()
            tintColor = UIColor.black
        }
    }

    let cellIdentifier = "autocompleteCellIdentifier"
    var isMapView = false
    var shouldDrawUnderline = false
    var shouldTintClearButton = true
    var tintedClearImage: UIImage?
    var fieldTintColor: UIColor?
    var tableHeight: CGSize?
    /// Manages the instance of tableview
    var autoCompleteTableView: UITableView?
    /// Holds the collection of attributed strings
    fileprivate lazy var attributedAutoCompleteStrings = [NSAttributedString]()
    /// Handles user selection action on autocomplete table view
    open var onSelect: (String, IndexPath) -> Void = { _, _ in }
    /// Handles textfield's textchanged
    open var onTextChange: (String) -> Void = { _ in }

    var autoCompleteTableWidth: CGFloat?
    /// Font for the text suggestions
    open var autoCompleteTextFont = UIFont.systemFont(ofSize: 20)
    /// Color of the text suggestions
    open var autoCompleteTextColor = UIColor.black
    /// Used to set the height of cell for each suggestions
    open var autoCompleteCellHeight: CGFloat = 60
    /// The maximum visible suggestion
    open var maximumAutoCompleteCount = 5
    /// Used to set your own preferred separator inset
    open var autoCompleteSeparatorInset = UIEdgeInsets.zero
    /// Shows autocomplete text with formatting
    open var enableAttributedText = false
    /// User Defined Attributes
    open var autoCompleteAttributes: [NSAttributedStringKey: AnyObject]?
    /// Hides autocomplete tableview after selecting a suggestion
    open var hidesWhenSelected = true
    /// Hides autocomplete tableview when the textfield is empty
    open var hidesWhenEmpty: Bool? {
        didSet {
            assert(hidesWhenEmpty != nil, "hideWhenEmpty cannot be set to nil")
            autoCompleteTableView?.isHidden = hidesWhenEmpty!
        }
    }
    /// The table view height
    open var autoCompleteTableHeight: CGFloat? {
        didSet {
            redrawTable()
        }
    }
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    open var autoCompleteStrings: [String]? {
        didSet { reload() }
    }

    open var autoCompletePlacesIds: [String]?
    var fistAutoCompletePlaceId: String?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        self.autocorrectionType = .no
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if shouldTintClearButton {
            tintClearImage()
        }
    }

    fileprivate func commonInit() {
        hidesWhenEmpty = true
        autoCompleteAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        autoCompleteAttributes![NSAttributedStringKey.font] = UIFont.boldSystemFont(ofSize: 12)
        self.clearButtonMode = .whileEditing
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidEndEditing), for: .editingDidEnd)
    }

    func setupAutocompleteTable(_ view: UIView) {
        let screenSize = UIScreen.main.bounds.size
        let tableView = UITableView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.height, width: screenSize.width, height: 30.0))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty ?? true

        view.addSubview(tableView)
        autoCompleteTableView = tableView

        autoCompleteTableHeight = 100.0
    }

    func setupAutocompleteTable(_ view: UIView, rootView: UIView) {
        let tableView = UITableView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + view.bounds.height + 1 + UIApplication.shared.statusBarFrame.size.height, width: view.bounds.width, height: autoCompleteCellHeight * 3))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty ?? true
        tableView.layer.cornerRadius = 10
        rootView.addSubview(tableView)
        autoCompleteTableView = tableView
        tableView.register(UINib(nibName: "AutoCompleteTableViewCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView.separatorStyle = .none
        print("setup autocompletetable called")
    }

    // MARK: - Private Methods
    fileprivate func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.image(for: .highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(uiImage, color: tintColor)
                    }
                    button.setImage(tintedClearImage, for: UIControlState())
                    button.setImage(tintedClearImage, for: .highlighted)
                }
            }
        }
    }

    fileprivate func tintImage(_ image: UIImage, color: UIColor) -> UIImage {
        let size = image.size

        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.zero, blendMode: CGBlendMode.normal, alpha: 1.0)

        context?.setFillColor(color.cgColor)
        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.setAlpha(1.0)

        let rect = CGRect(
            x: CGPoint.zero.x,
            y: CGPoint.zero.y,
            width: image.size.width,
            height: image.size.height)
        UIGraphicsGetCurrentContext()?.fill(rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage!
    }

    fileprivate func redrawTable() {
        if let autoCompleteTableView = autoCompleteTableView, let autoCompleteTableHeight = autoCompleteTableHeight, let autoCompleteTableWidth = autoCompleteTableWidth {
            var newFrame = autoCompleteTableView.frame
            newFrame.size.height = autoCompleteTableHeight
            newFrame.size.width = autoCompleteTableWidth
            print(newFrame)
            autoCompleteTableView.frame = newFrame
            print(autoCompleteTableView.frame)
            self.autoCompleteTableView?.superview?.bringSubview(toFront: autoCompleteTableView)
        }
    }

    fileprivate func reload() {

        self.autoCompleteTableView?.isHidden = self.hidesWhenEmpty! ? self.text!.isEmpty : false

        if autoCompleteStrings == nil || autoCompleteStrings?.count == 0 {
            self.autoCompleteTableView?.isHidden = true
            return
        }

        if enableAttributedText {
            let attrs = [NSAttributedStringKey.foregroundColor: autoCompleteTextColor, NSAttributedStringKey.font: autoCompleteTextFont] as [NSAttributedStringKey: Any]

            if attributedAutoCompleteStrings.count > 0 {
                attributedAutoCompleteStrings.removeAll(keepingCapacity: false)
            }

            if let autoCompleteStrings = autoCompleteStrings, let autoCompleteAttributes = autoCompleteAttributes {
                for i in 0 ..< autoCompleteStrings.count {
                    let str = autoCompleteStrings[i] as NSString
                    let range = str.range(of: text!, options: .caseInsensitive)
                    let attString = NSMutableAttributedString(string: autoCompleteStrings[i], attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes, range: range)
                    attributedAutoCompleteStrings.append(attString)
                }
            }
        }
        if isMapView {
            autoCompleteTableView?.reloadData()
            if autoCompleteStrings != nil {
                autoCompleteTableHeight = autoCompleteCellHeight * CGFloat(maximumAutoCompleteCount)
                redrawTable()
            }
        } else {
            autoCompleteTableView?.reloadData()
        }
    }

    @objc func textFieldDidChange() {
        guard let _ = text else {
            return
        }

        onTextChange(text!)
        if text!.isEmpty { autoCompleteStrings = nil }
    }

    @objc func textFieldDidEndEditing() {
        debugPrint("textfielddidendediting")
        self.autoCompleteTableView?.isHidden = true
        DispatchQueue.main.async(execute: { () in
            self.autoCompleteTableView?.isHidden = true
        })
    }
}

// MARK: - UITableViewDataSource - UITableViewDelegate
extension AutoCompleteTextField: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return autoCompleteStrings != nil ? (autoCompleteStrings!.count > maximumAutoCompleteCount ? maximumAutoCompleteCount : autoCompleteStrings!.count) : 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? AutoCompleteTableViewCell else {
            return UITableViewCell()
        }

        if enableAttributedText {
            cell.locationNameLabel.attributedText = attributedAutoCompleteStrings[(indexPath as NSIndexPath).row]
        } else {
            cell.locationNameLabel?.font = autoCompleteTextFont
            cell.locationNameLabel?.textColor = autoCompleteTextColor
            cell.locationNameLabel?.text = autoCompleteStrings![(indexPath as NSIndexPath).row]
        }
        cell.layer.cornerRadius = 5
        cell.contentView.gestureRecognizers = nil
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AutoCompleteTableViewCell else {
            return
        }

        if let selectedText = cell.locationNameLabel?.text {
            self.text = selectedText
            onSelect(selectedText, indexPath)
        }

        DispatchQueue.main.async(execute: { () in
            tableView.isHidden = self.hidesWhenSelected
        })
    }

    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = autoCompleteSeparatorInset
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = autoCompleteSeparatorInset
        }
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
}
