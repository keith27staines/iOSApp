//
//  ApplicationLetterViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

public protocol ApplicationLetterViewControllerCoordinating : class {
    func cancelButtonWasTapped(sender: Any?)
    func editButtonWasTapped(sender: Any?)
    func continueApplicationWithCompletedLetter(sender: Any?, completion: @escaping (Error?) -> Void)
    func termsAndConditionsWasTapped(sender: Any?)
}

public class ApplicationLetterViewController : UIViewController {
    
    weak var coordinator: ApplicationLetterViewControllerCoordinating?
    var mainView: ApplicationLetterViewControllerMainView { return view as! ApplicationLetterViewControllerMainView }
    let editButton: EditApplicationLetterButton = EditApplicationLetterButton()
    var termsAndConditionsButton: UIButton { return mainView.termsAndConditionsButton }
    var applyButton: UIButton { return mainView.applyButton }
    var textView: UITextView { return mainView.textView }
    
    let cancelButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        return button
    }()
    
    lazy var userMessageHandler: UserMessageHandler = {
        return UserMessageHandler()
    }()
    
    public var isActivityIndicatorVisible: Bool {
        didSet {
            if isActivityIndicatorVisible {
                userMessageHandler.showLightLoadingOverlay(view)
            } else {
                userMessageHandler.hideLoadingOverlay()
            }
        }
    }
    
    var viewModel: ApplicationLetterViewModelProtocol {
        didSet {
            viewModel.view = self
            updateFromViewModel()
        }
    }
    
    public init(
        coordinator: ApplicationLetterViewControllerCoordinating,
        viewModel: ApplicationLetterViewModelProtocol) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.isActivityIndicatorVisible = false
        super.init(nibName: nil, bundle: nil)
        viewModel.view = self
        viewModel.coordinator = coordinator
    }
    
    public override func viewDidLoad() {
        applySkin()
        configureNavigationBar()
        setTargetsForButtons()
        updateFromViewModel()
        viewModel.onViewDidLoad()
    }
    
    public func updateFromViewModel() {
        textView.attributedText = viewModel.attributedText
        applyButton.isEnabled = viewModel.applyButtonIsEnabled
        editButton.configureForLetterIsCompleteState(viewModel.applyButtonIsEnabled)
    }
    
    func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.darkText
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }
    
    func setTargetsForButtons() {
        termsAndConditionsButton.addTarget(self, action: #selector(termsAndConditionsButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: UIControl.Event.touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        let tapRecogniser = UITapGestureRecognizer(target: self, action:  #selector(editButtonTapped))
        textView.addGestureRecognizer(tapRecogniser)
    }
    
    func applySkin() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: applyButton)
    }
    
    public override func loadView() {
        view = ApplicationLetterViewControllerMainView()
    }
    
    @objc func cancelButtonTapped(sender: Any?) {
        coordinator?.cancelButtonWasTapped(sender: sender)
    }
    
    @objc func editButtonTapped(sender: Any?) {
        coordinator?.editButtonWasTapped(sender: sender)
    }
    
    @objc func applyButtonTapped(sender: Any?) {
        viewModel.applyButtonWasTapped()
    }
    
    @objc func termsAndConditionsButtonTapped(sender: Any?) {
        viewModel.termsAndConditionsButtonWasTapped(sender: self)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

extension ApplicationLetterViewController : ApplicationLetterViewProtocol {
    
    public func showErrorWithCancelAndRetry(_ error: Error, retry: @escaping () -> Void, cancel: @escaping () -> Void) {
        var wexError: WEXError
        if let wex = error as? WEXError {
            wexError = wex
        } else {
            wexError = WEXErrorsFactory.networkErrorFrom(error: error, attempting: "")
        }
        userMessageHandler.displayCancelRetryAlertFor(wexError, parentCtrl: self, cancelHandler: cancel, retryHandler: retry)
    }
}
