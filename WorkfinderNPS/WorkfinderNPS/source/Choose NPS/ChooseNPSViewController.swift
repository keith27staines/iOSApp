//
//  ChooseNPS.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class ChooseNPSViewController: BaseViewController {
    
    var chooseNPSPresenter: ChooseNPSPresenter? { return presenter as? ChooseNPSPresenter }
    
    override func viewDidLoad() {
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
        presenter.onViewDidLoad(vc: self)
        reload()
        addNotificationListeners()
    }
    
    private func addNotificationListeners() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            questionsView.table.contentInset = .zero
        } else {
            questionsView.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        questionsView.table.scrollIndicatorInsets = questionsView.table.contentInset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Review"
    }
    
    func reload() {
        messageHandler.showLoadingOverlay()
        chooseNPSPresenter?.reload() { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.cancelButtonTap()
            } retryHandler: {
                self.reload()
            }
            self.refreshFromPresenter()
        }
    }
    
    func refreshFromPresenter() {
        let intro = chooseNPSPresenter?.introText
        let score = chooseNPSPresenter?.score
        scoreView.configureWith(introText: intro, score: score)
        questionsView.configureWith(category: presenter.category)
    }
    
    func showAnswerTextFor(question: Question,  onCancel: @escaping () -> Void, onDone: @escaping (String?) -> Void) {
        let vc = AnswerTextViewController(
            title: "Other",
            intro: "Some intro text",
            text: question.answer.answerText,
            onCancel: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                onCancel()
            },
            onDone: { [weak self] string in
                self?.navigationController?.popViewController(animated: true)
                onDone(string)
            }
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private lazy var scoreView = NPSScoreView() { [weak self] score in
        guard let self = self else { return }
        self.chooseNPSPresenter?.setScore(score)
        self.refreshFromPresenter()
    }
    
    private lazy var questionsView: QuestionsView = {
        QuestionsView(parent: self)
    }()
    
    private lazy var nextButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.addArrangedSubview(nextButton)
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.spacing = 0
        stack.axis = .horizontal
        return stack
    }()
    
    private lazy var nextButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        return button
    }()
    
    @objc private func onNext() {
        coordinator?.showSubmit()
    }
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(scoreView)
        stack.addArrangedSubview(questionsView)
        stack.addArrangedSubview(nextButtonStack)
        stack.spacing = 12
        stack.axis = .vertical
        return stack
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIView {
    
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder { return self }
        for view in subviews {
            if let firstResponder = view.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
}
