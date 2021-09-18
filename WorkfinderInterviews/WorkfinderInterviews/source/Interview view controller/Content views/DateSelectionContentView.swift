//
//  DateSelectionContentView.swift
//  WorkfinderInterviews
//
//  Created by Keith on 18/09/2021.
//

import UIKit
import WorkfinderUI

class DateSelectionContentView: UIView, InterviewPresenting {
    
    var presenter: InterviewPresenter?
    weak var messageHandler: UserMessageHandler?
    
    func updateFromPresenter() {
        dateLabel.text = presenter?.dateString
        timeLabel.text = presenter?.timeString
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = WorkfinderColors.gray3
        label.text = "title"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(dateLabel)
        stack.addArrangedSubview(timeLabel)
        stack.spacing = 12
        return stack
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = WorkfinderColors.gray3
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = WorkfinderColors.gray3
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()


    lazy var acceptButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Accept", for: .normal)
        button.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapAcceptButton() {
        messageHandler?.showLoadingOverlay()
        presenter?.onDidTapAccept { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler?.hideLoadingOverlay()
            self.messageHandler?.displayOptionalErrorIfNotNil(optionalError) {
                
            } retryHandler: {
                self.didTapAcceptButton()
            }
        }
    }
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(dateStack)
        stack.addArrangedSubview(acceptButton)
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
