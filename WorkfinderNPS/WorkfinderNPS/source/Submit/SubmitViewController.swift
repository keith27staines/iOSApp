//
//  FeedbackChoicesViewController.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class SubmitViewController: BaseViewController {
    
    lazy var intro: UILabel = {
        let label = UILabel()
        label.text = "Your feedback is highly valuable to {{Host First Name}}, {{Company Name}} and us. This helps us improve our service so that you and other candidates won’t have similar experience again. You can choose to hide your name and details when sharing your feedback."
        label.textColor = WorkfinderColors.gray2
        label.numberOfLines = 0
        return label
    }()
    
    lazy var goodFeedbackButton: UIButton = {
        let button = UIButton()
        button.setTitle("(What makes a good feedback?)", for: .normal)
        button.addTarget(self, action: #selector(linkToFeedback), for: .touchUpInside)
        return button
    }()
    
    lazy var hideDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = "Hide my name and details when sharing feedback"
        label.textColor = WorkfinderColors.gray4
        return label
    }()
    
    lazy var hideDetailsSwitch: UISwitch = {
        let view = UISwitch()
        return view
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(intro)
        stack.addArrangedSubview(goodFeedbackButton)
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    lazy var switchStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(hideDetailsLabel)
        stack.addArrangedSubview(hideDetailsSwitch)
        
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(switchStack)
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    @objc func linkToFeedback() {
        
    }
    
    lazy var shareButton: UIButton = {
        
    }()
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(stack)
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor)
        
    }
    
    override func viewDidLoad() {
        configureViews()
        styleNavigationController()
        navigationItem.title = "Share"
    }
    
    
}

