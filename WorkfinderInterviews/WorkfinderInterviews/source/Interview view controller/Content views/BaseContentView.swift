//
//  BaseContentView.swift
//  WorkfinderInterviews
//
//  Created by Keith on 20/09/2021.
//

import UIKit
import WorkfinderUI

class BaseContentView: UIView, InterviewPresenting {
    
    weak var messageHandler: UserMessageHandler?
    var presenter: InterviewPresenter? {
        didSet {
            guard let presenter = presenter else { return }
            presenter.interviewDateSelectionDidChange = { [weak self] in
                self?.primaryButton.isEnabled = presenter.isprimaryButtonEnabled
            }
        }
    }
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.sectionTitle
        label.applyStyle(style)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    lazy var introText: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.bodyTextRegular
        label.applyStyle(style)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    lazy var primaryButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        button.setTitleColor(.white, for: .disabled)
        return button
    }()
    
    lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(WFColorPalette.salmon, for: .normal)
        button.addTarget(self, action: #selector(didTapSecondaryButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapPrimaryButton() {
        messageHandler?.showLoadingOverlay()
        presenter?.onDidTapPrimaryButton() { [weak self] optionalError in
            guard let self = self else { return }
            self.tapCompletionHandler(optionalError: optionalError, retryHandler: self.didTapPrimaryButton)
        }
    }
    
    @objc func didTapSecondaryButton() {
        messageHandler?.showLoadingOverlay()
        presenter?.onDidTapSecondaryButton() { [weak self] optionalError in
            guard let self = self else { return }
            self.tapCompletionHandler(optionalError: optionalError, retryHandler: self.didTapSecondaryButton)
        }
    }
    
    func tapCompletionHandler(optionalError: Error?, retryHandler: @escaping () -> Void) {
        self.messageHandler?.hideLoadingOverlay()
        self.messageHandler?.displayOptionalErrorIfNotNil(optionalError) {
        } retryHandler: {
            retryHandler()
        }
    }

    func updateFromPresenter() {
        guard let presenter = presenter else { return }
        titleLabel.text = presenter.title
        introText.text = presenter.introText
        primaryButton.setTitle(presenter.primaryButtonEnabledText, for: .normal)
        primaryButton.setTitle(presenter.primaryButtonDisabledText, for: .disabled)
        primaryButton.isEnabled = presenter.isprimaryButtonEnabled
        secondaryButton.setTitle(presenter.secondaryButtonEnabledText, for: .normal)
    }
    
    func configureMainStack() {
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 16))
        mainStack.addArrangedSubview(introText)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 24))
        mainStack.addArrangedSubview(primaryButton)
        mainStack.addArrangedSubview(secondaryButton)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 24))
    }
    
    func configureViews() {
        addSubview(mainStack)
        configureMainStack()
        secondaryButton.heightAnchor.constraint(equalTo: primaryButton.heightAnchor).isActive = true
    }
    
    func makeVerticalSpace(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    init() {
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

