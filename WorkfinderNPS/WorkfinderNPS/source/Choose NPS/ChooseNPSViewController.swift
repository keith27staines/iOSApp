//
//  ChooseNPS.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class ChooseNPSViewController: BaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Review"
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        stack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        presenter.onViewDidLoad(vc: self)
        reload()
    }
    
    func reload() {
        messageHandler.showLoadingOverlay()
        presenter.reload() { [weak self] optionalError in
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
        scoreView.configureWith(introText: presenter.introText, score: presenter.score)
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
        self.presenter.setScore(score)
        self.refreshFromPresenter()
    }
    private lazy var questionsView: QuestionsView = {
        QuestionsView(parent: self)
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
        stack.addArrangedSubview(nextButton)
        stack.spacing = 20
        stack.axis = .vertical
        return stack
    }()
}
