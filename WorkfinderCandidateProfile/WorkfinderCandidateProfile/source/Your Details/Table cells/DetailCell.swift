//
//  TextFieldCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 12/04/2021.
//

import UIKit
import WorkfinderUI

class DetailCell:  UITableViewCell {
    
    var presenter: DetailCellPresenter?
    
    lazy var titleLabel:  UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 0.56, alpha: 1)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var titleAsterisk:  UILabel = {
        let asterisk = " *"
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = asterisk
        label.textColor = UIColor(red:0.86, green:0.25, blue:0.25, alpha:1)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var titleStack: UIStackView = {
        let space = UIView()
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: [
                titleLabel,
                titleAsterisk,
                space
            ]
        )
        let width = stack.widthAnchor.constraint(equalToConstant: 1000)
        width.priority = .defaultHigh
        width.isActive = true
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    lazy var descriptionLabel:  UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.init(white: 0.56, alpha: 1)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
/*
    lazy var textfield:  UITextField = {
        let text = UITextField()
        text.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        text.textColor = UIColor.init(white: 0.15, alpha: 1)
        text.borderStyle = .roundedRect
        text.setContentHuggingPriority(.defaultLow, for: .horizontal)
        text.setContentHuggingPriority(.defaultHigh, for: .vertical)
        text.delegate = self
        return text
    }()
*/
    
    lazy var textfieldStack: ValidatedTextFieldStack = {
        let stack = ValidatedTextFieldStack(state: .empty)
        stack.textfield.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        stack.textfield.textColor = UIColor.init(white: 0.15, alpha: 1)
        stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        stack.textfield.delegate = self
        stack.textfield.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return stack
    }()
    
    @objc func textChanged() {
        guard let text = textfieldStack.textfield.text else {
            textfieldStack.state = .empty
            return
        }
        let validity = presenter?.type.textValidityState?(text) ?? ValidityState.empty
        switch validity {
        case .good:
            textfieldStack.state = .good
        case .bad:
            textfieldStack.state = .bad
        case .empty, .isNil:
            textfieldStack.state = .empty
        }
    }
    
    lazy var dateField: UITextField = {
        let text = UITextField()
        text.borderStyle = .roundedRect
        text.inputView = datePicker
        text.setContentHuggingPriority(.defaultHigh, for: .vertical)
        let bar = UIToolbar()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(forceEndEditing))
        bar.items = [cancelButton]
        bar.sizeToFit()
        text.inputAccessoryView = bar
        return text
    }()
    
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(onDateChosen), for: .valueChanged)
        return datePicker
    }()
    
    @objc func forceEndEditing() {
        endEditing(true)
    }
    
    @objc func onDateChosen() {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        dateField.text = df.string(from: datePicker.date)
        dateField.endEditing(true)
    }
    
    lazy var leftStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                titleStack,
                descriptionLabel
            ]
        )
        stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()
    
    lazy var disclosureLabel:  UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = WorkfinderColors.primaryColor
        label.textColor = WorkfinderColors.primaryColor
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                leftStack,
                disclosureLabel
            ]
        )
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fill
        return stack
    }()

    
    func configureWith(presenter: DetailCellPresenter) {
        let type = presenter.type
        self.presenter = presenter
        titleLabel.text = type.title
        descriptionLabel.text = type.description
        
        titleLabel.isHidden = type.title == nil
        titleAsterisk.isHidden = !type.isRequired || titleLabel.isHidden
        descriptionLabel.isHidden = type.description == nil
        let textfield = textfieldStack.textfield
        switch type.dataType {
        case .text(let textType):
            leftStack.addArrangedSubview(textfieldStack)
            textfield.placeholder = type.placeholderText
            switch textType {
            case .fullname:
                textfield.autocapitalizationType = .words
                textfield.autocorrectionType = .no
                textfield.textContentType = .name
                textfield.keyboardType = .default
            case .email:
                textfield.autocapitalizationType = .none
                textfield.autocorrectionType = .no
                textfield.textContentType = .emailAddress
                textfield.keyboardType = .emailAddress
            case .phone:
                textfield.autocapitalizationType = .none
                textfield.autocorrectionType = .no
                textfield.textContentType = .telephoneNumber
                textfield.keyboardType = .phonePad
            case .postcode:
                textfield.autocapitalizationType = .allCharacters
                textfield.autocorrectionType = .no
                textfield.textContentType = .postalCode
                textfield.keyboardType = .default
            }
        case .date:
            leftStack.addArrangedSubview(dateField)
            dateField.placeholder = type.placeholderText
        case .none:
            break
        case .picklist(let picklistType):
            break
        }
        disclosureLabel.text = presenter.disclosureText
        disclosureLabel.isHidden = (presenter.disclosureText ?? "").isEmpty
        accessoryType = presenter.accessoryType
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailCell: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.isEmpty == false else {
            return (presenter?.type.isRequired ?? false) ? false : true
        }
        return presenter?.type.textValidator?(textfieldStack.textfield.text) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textfieldStack.textfield.resignFirstResponder()
        
    }
}
