//
//  PreferencesViewController.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 10/04/2021.
//

import Foundation
import UIKit
import WorkfinderCommon

class PreferencesViewController:  WFViewController {
    
    var preferencesPresenter: PreferencesPresenter { presenter as! PreferencesPresenter }
    weak var removeAction: UIAlertAction?
    var capturedEmail: String = ""
    
    @objc func alertTextfieldChanged(textfield: UITextField) {
        capturedEmail = textfield.text ?? ""
        removeAction?.isEnabled = capturedEmail.isEmail()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesPresenter.viewController = self
    }
    
    func removeAccountRequested() {
        guard let coordinator = coordinator else { return }
        let vc = RemoveAccountViewController(coordinator: coordinator)
        navigationController?.present(vc, animated: true, completion: nil)
        return
        
        let alert = UIAlertController(
            title: "Are you sure you want us to remove your account?",
            message: "We will delete your details from our database. This cannot be undone.\nPlease enter your email to confirm",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            self.coordinator?.permanentlyRemoveAccountFromServer(email: self.capturedEmail) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.removeAccountCompleted()
                case .failure(let error):
                    self.messageHandler.displayOptionalErrorIfNotNil(error) {
                        return
                    } retryHandler: {
                        self.removeAccountRequested()
                    }
                }
            }
        }
        removeAction.isEnabled = false
        self.removeAction = removeAction
    
        alert.addTextField { [weak self] textfield in
            guard let self = self else { return }
            textfield.addTarget(self, action: #selector(self.alertTextfieldChanged), for: .editingChanged)
        }
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        present(alert, animated: true, completion: nil)
    }
    
    func removeAccountCompleted() {
        let alert = UIAlertController(
            title: "Account deleted",
            message: "We are arranging for the deletion of your details as you requested, and you are now logged out. Thank you for using Workfinder.",
            preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { [weak self] (action) in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func registerTableCells() {
        tableView.register(EnableNotificationsCell.self, forCellReuseIdentifier: EnableNotificationsCell.reuseIdentifier)
        tableView.register(NotificationControlsCell.self, forCellReuseIdentifier: NotificationControlsCell.reuseIdentifier)
        tableView.register(MarketingEmailCell.self, forCellReuseIdentifier: MarketingEmailCell.reuseIdentifier)
        tableView.register(RemoveAccountCell.self, forCellReuseIdentifier: RemoveAccountCell.reuseIdentifier)
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Account Preferences"
    }
    
    init(coordinator: AccountCoordinator, presenter: PreferencesPresenter) {
        super.init(coordinator: coordinator, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
