//
//  YourDetailsViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import UIKit
import WorkfinderCommon

class YourDetailsViewController:  WFViewController {
    
    var yourDetailsPresenter: YourDetailsPresenter { presenter as! YourDetailsPresenter }
    
    override func registerTableCells() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourDetailsPresenter.viewController = self
        addNotificationListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMovingToParent {
            super.viewWillAppear(animated)
        } else {
            
        }
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
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Your Details"
        navigationItem.rightBarButtonItem = updateButton
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    lazy var updateButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(update))
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }()
    
    func onDetailsChanged() {
        updateButton.isEnabled = yourDetailsPresenter.isUpdateEnabled
    }
    
    @objc func update() {
        messageHandler.showLightLoadingOverlay()
        yourDetailsPresenter.syncAccountToServer() { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                return
            } retryHandler: {
                self.update()
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    init(coordinator: AccountCoordinator, presenter: YourDetailsPresenter) {
        super.init(coordinator: coordinator, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
