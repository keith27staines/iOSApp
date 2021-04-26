//
//  OtherFeedbackViewController.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class ThankyouViewController: BaseViewController {
    
    lazy var thankyou: UILabel = {
        let label = UILabel()
        label.text = "Thank you for sharing your feedback!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    lazy var text: UILabel = {
        let label = UILabel()
        label.text = "Your feedback will be used to help the host to improve and become better at hosting work experience"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = WorkfinderColors.gray4
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var finishedButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Finished", for: .normal)
        button.addTarget(self, action: #selector(finished), for: .touchUpInside)
        return button
    }()
    
    @objc func finished() {
        coordinator?.finishedNPS()
    }
    
    lazy var modifyButton: UIButton = {
        let button = WorkfinderSecondaryButton()
        button.setTitle("Modify review", for: .normal)
        button.addTarget(self, action: #selector(modify), for: .touchUpInside)
        return button
    }()
    
    @objc func modify() {
        coordinator?.backToStart()
    }
    
    lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(modifyButton)
        stack.addArrangedSubview(finishedButton)
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(thankyou)
        stack.addArrangedSubview(text)
        stack.spacing = 20
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(buttonsStack)
        stack.spacing = 20
        return stack
    }()
    
    override func viewDidLoad() {
        configureNavigationBar()
        configureViews()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(mainStack)
        mainStack.anchor(top: nil, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
    }
    
    func configureNavigationBar() {
        styleNavigationController()
        navigationItem.title = "Thank you!"
        navigationItem.hidesBackButton = true
    }

}

