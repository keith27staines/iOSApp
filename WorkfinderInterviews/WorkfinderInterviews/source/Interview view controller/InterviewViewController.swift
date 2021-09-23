//
//  AcceptInvite.swift
//  WorkfinderInterviews
//
//  Created by Keith on 14/07/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderServices
import WorkfinderUI

class InterviewViewController: UIViewController, InterviewPresenting {

    weak var coordinator: AcceptInviteCoordinatorProtocol?
    var messageHandler: UserMessageHandler?
    var presenter: InterviewPresenter?
    
    var currentContent: (UIView & InterviewPresenting)?

    func setContentState() {
        guard let presenter = presenter else { return }
        let contentForState: BaseContentView
        switch presenter.contentState {
        case .dateSelecting:
            contentForState = dateSelectionContentView
        case .accepted:
            contentForState = acceptedContentView
        case .declining:
            contentForState = decliningContentView
        case .declined:
            contentForState = declinedContentView
        }
        setContent(contentForState)
        thumb.alpha = presenter.isCancelPermitted == true ? 1 : 0
    }
    
    func setContent(_ content: UIView & InterviewPresenting) {
        removeContent()
        contentContainer.addSubview(content)
        content.anchor(top: contentContainer.topAnchor, leading: contentContainer.leadingAnchor, bottom: contentContainer.bottomAnchor, trailing: contentContainer.trailingAnchor)
        content.updateFromPresenter()
        content.alpha = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.solidBackgroundView.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                content.alpha = 1
            }
        }
        self.currentContent = content
    }
    
    func removeContent() {
        currentContent?.removeFromSuperview()
    }
    
    init(coordinator: AcceptInviteCoordinatorProtocol, presenter: InterviewPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.interviewViewController = self
        self.messageHandler = UserMessageHandler(presenter: self)
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        load()
    }
    
    lazy var thumb: UIView = {
        let height = CGFloat(4)
        let view = UIView()
        view.backgroundColor = WFColorPalette.offWhite
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.widthAnchor.constraint(equalToConstant: 80).isActive = true
        view.layer.cornerRadius = height/2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var contentContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var dateSelectionContentView: DateSelectionContentView = {
        let view = DateSelectionContentView()
        view.presenter = presenter
        view.messageHandler = messageHandler
        return view
    }()
    
    lazy var acceptedContentView: AcceptedContentView = {
        let view = AcceptedContentView()
        view.presenter = presenter
        view.messageHandler = messageHandler
        return view
    }()
    
    lazy var decliningContentView: DecliningContentView = {
        let view = DecliningContentView()
        view.presenter = presenter
        view.messageHandler = messageHandler
        return view
    }()

    lazy var declinedContentView: DeclinedContentView = {
        let view = DeclinedContentView()
        view.presenter = presenter
        view.messageHandler = messageHandler
        return view
    }()

    private func load() {
        messageHandler?.showLoadingOverlay()
        presenter?.load { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler?.hideLoadingOverlay()
            self.messageHandler?.displayOptionalErrorIfNotNil(optionalError) {
                self.coordinator?.didComplete(withChanges: false)
            } retryHandler: {
                self.load()
            }
            self.updateFromPresenter()
        }
    }
    
    func updateFromPresenter() {
        setContentState()
    }
    
    func configureNaviationBar() {
        styleNavigationController()
    }
    
    var bottom: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    
    lazy var solidBackgroundView: UIView = {
        let solid = UIView()
        solid.backgroundColor = UIColor.white
        let view = self.view!
        self.view.addSubview(solid)
        solid.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        bottom = solid.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        height?.isActive = true
        bottom?.isActive = true
        solid.clipsToBounds = true
        solid.layer.cornerRadius = 16
        solid.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        solid.layer.borderWidth = 1
        solid.layer.borderColor = WFColorPalette.border.cgColor
        solid.addSubview(thumb)
        thumb.topAnchor.constraint(equalTo: solid.topAnchor, constant: WFMetrics.standardSpace).isActive = true
        thumb.centerXAnchor.constraint(equalTo: solid.centerXAnchor).isActive = true
        return solid
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.clear
        view.addSubview(solidBackgroundView)
        solidBackgroundView.addSubview(contentContainer)
        let guide = solidBackgroundView.safeAreaLayoutGuide
        contentContainer.anchor(top: thumb.bottomAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).y
        if translation > 0 {
            if solidBackgroundView.frame.height - translation > 100 {
                self.bottom?.constant = translation
            }
            if translation > 150 && presenter?.isCancelPermitted == true {
                coordinator?.didComplete(withChanges: false)
            } else {
                if gesture.state == .ended {
                    self.bottom?.constant = 0
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





