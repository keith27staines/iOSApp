//
//  FeedbackChoicesViewController.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class SubmitViewController: BaseViewController {
    
    var submitPresenter: SubmitPresenter? { presenter as? SubmitPresenter }
    
    lazy var table: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.backgroundColor = UIColor.white
        table.tableFooterView = UIView()
        return table
    }()
    
    lazy var intro: UILabel = {
        let label = UILabel()
        label.textColor = WorkfinderColors.gray2
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    lazy var goodFeedbackStack: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(goodFeedbackButton)
        stack.addArrangedSubview(spacer)
        return stack
    }()
    
    lazy var goodFeedbackButton: UIButton = {
        let button = UIButton()
        button.setTitle("(What makes good feedback?)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(WorkfinderColors.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(linkToFeedback), for: .touchUpInside)
        return button
    }()
    
    lazy var hideDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Hide my name and details when sharing feedback"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 2
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var hideDetailsSwitch: UISwitch = {
        let view = UISwitch()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.addTarget(self, action: #selector(hideDetails), for: .valueChanged)
        return view
    }()
    
    lazy var introStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(intro)
        stack.addArrangedSubview(goodFeedbackStack)
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    lazy var hideDetailsStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(hideDetailsLabel)
        stack.addArrangedSubview(hideDetailsSwitch)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var feedback: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 17)
        view.textColor = WorkfinderColors.gray2
        view.layer.borderWidth = 1
        view.layer.borderColor = WorkfinderColors.gray4.cgColor
        view.layer.cornerRadius = 12
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        view.inputAccessoryView = keyboardToolbar
        view.delegate = self
        return view
    }()
    
    lazy var primaryButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Submit review", for: .normal)
        button.addTarget(self, action: #selector(submitReview), for: .touchUpInside)
        return button
    }()
    
    @objc func hideDetails(switchControl: UISwitch) {
        submitPresenter?.isAnonymous = switchControl.isOn
    }
    
    @objc func submitReview() {
        submitPresenter?.submitReview(completion: { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                
            } retryHandler: {
                self.submitReview()
            }
            self.coordinator?.showThankyou()
        })
    }
    
    lazy var keyboardToolbar: UIToolbar = {
        let bar = UIToolbar()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeKeyboard))
        bar.items = [done]
        bar.backgroundColor = UIColor.white
        bar.sizeToFit()
        return bar
    }()
    
    @objc func closeKeyboard() {
        feedback.resignFirstResponder()
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(introStack)
        stack.addArrangedSubview(hideDetailsStack)
        stack.addArrangedSubview(feedback)
        stack.addArrangedSubview(primaryButton)
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()
    
    @objc func linkToFeedback() {
        let title = "What makes good feedback?"
        let goodFeedbackAdvice = "You could congratulate the host for things you think they did well, and/or suggest suggest things that might help the host offer others better work experience in the future."
        let alert = UIAlertController(title: title, message: goodFeedbackAdvice, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        //coordinator?.presentContent(.whatMakesGoodFeedback)
    }
    
    lazy var shareButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        return button
    }()
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(table)
        table.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    override func viewDidLoad() {
        configureViews()
        configureNavigationBar()
        addNotificationListeners()
        reloadFromPresenter()
    }
    
    func reloadFromPresenter() {
        intro.text = submitPresenter?.feedbackIntro
        feedback.text = submitPresenter?.feedbackText
        hideDetailsSwitch.isOn = submitPresenter?.isAnonymous ?? true
    }
    
    func configureNavigationBar() {
        styleNavigationController()
        navigationItem.title = "Add feedback"
    }
    
    private func addNotificationListeners() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            table.contentInset = .zero
        } else {
            table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        table.scrollIndicatorInsets = table.contentInset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SubmitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let content = cell.contentView
        content.addSubview(stack)
        stack.anchor(top: content.topAnchor, leading: content.leadingAnchor, bottom: content.bottomAnchor, trailing: content.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        return cell
    }
}

extension SubmitViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        submitPresenter?.feedbackText = textView.text
    }
}

