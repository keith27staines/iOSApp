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

    private func setContentState() {
        guard let presenter = presenter else { return }
        removeContent()
        switch presenter.contentState {
        case .dateSelecting:
            setContent(content: dateSelectionContentView)
        case .accepted:
            setContent(content: acceptedContentView)
        case .declining:
            setContent(content: decliningContentView)
        case .declined:
            setContent(content: declinedContentView)
        }
    }
    
    func setContent(content: UIView & InterviewPresenting) {
        contentContainer.addSubview(content)
        content.anchor(top: contentContainer.topAnchor, leading: contentContainer.leadingAnchor, bottom: contentContainer.bottomAnchor, trailing: contentContainer.trailingAnchor)
        content.updateFromPresenter()
        self.currentContent = content
    }
    
    func removeContent() {
        currentContent?.removeFromSuperview()
    }
    
    init(coordinator: AcceptInviteCoordinatorProtocol, presenter: InterviewPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.viewController = self
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
                self.coordinator?.acceptViewControllerDidCancel(self)
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
        height = solid.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8, constant: 0)
        bottom = solid.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        height?.isActive = true
        bottom?.isActive = true
        solid.clipsToBounds = true
        solid.layer.cornerRadius = 10
        solid.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        solid.layer.borderWidth = 1
        solid.layer.borderColor = WFColorPalette.grayBorder.cgColor
        solid.addSubview(thumb)
        thumb.topAnchor.constraint(equalTo: solid.topAnchor, constant: WFMetrics.standardSpace).isActive = true
        thumb.centerXAnchor.constraint(equalTo: solid.centerXAnchor).isActive = true
        solid.addSubview(contentContainer)
        contentContainer.anchor(top: thumb.bottomAnchor, leading: solid.leadingAnchor, bottom: solid.bottomAnchor, trailing: solid.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        return solid
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.clear
        let guide = solidBackgroundView.safeAreaLayoutGuide
        view.addSubview(solidBackgroundView)
        solidBackgroundView.addSubview(contentContainer)
        contentContainer.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).y
        if translation > 0 {
            self.bottom?.constant = translation
            if translation > 100 {
                dismiss(animated: true, completion: nil)
                coordinator?.didComplete(with: false)
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





