//
//  TextEditorViewController.swift
//  WorkfinderNPS
//
//  Created by Keith Staines on 26/04/2021.
//

import UIKit
import WorkfinderUI


class AnswerTextViewController: UIViewController {
    
    lazy var intro: UILabel = {
        let label = UILabel()
        label.textColor = WorkfinderColors.gray2
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    lazy var text: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor.white
        view.textColor = WorkfinderColors.gray2
        view.font = UIFont.systemFont(ofSize: 17)
        view.layer.borderWidth = 1
        view.layer.borderColor = WorkfinderColors.gray4.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var stack: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView()
        stack.addArrangedSubview(intro)
        stack.addArrangedSubview(text)
        stack.addArrangedSubview(spacer)
        stack.axis = .vertical
        stack.spacing = 20
        stack.heightAnchor.constraint(equalToConstant: 300).isActive = true
        return stack
    }()
    
    
    func fdafdas() {
        intro.text = textString
        text.text = textString
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
    }
    
    func confiugureNavigationBar() {
        styleNavigationController()
        self.title = title
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
    }
    
    var onDone: ((String?) -> Void)?
    var onCancel: (() -> Void)?
    
    @objc func done() {
        onDone?(textString)
    }
    
    @objc func cancel() {
        onCancel?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        confiugureNavigationBar()
        text.becomeFirstResponder()
    }
    
    var introString: String? {
        get { intro.text }
        set { intro.text = newValue }
    }
    
    var textString: String? {
        get { text.text }
        set { text.text = newValue }
    }
    
    
    init(title: String,
         intro: String?,
         text: String?,
         onCancel: @escaping () -> Void,
         onDone: @escaping (String?) -> Void
    ) {
        super.init(nibName: nil, bundle: nil)
        configureViews()
        self.title = title
        self.introString = intro
        self.textString = text
        self.onCancel = onCancel
        self.onDone = onDone
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
