//
//  ApplicationLetterViewModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

protocol ApplicationLetterViewProtocol : class {
    var isActivityIndicatorVisible: Bool { get set }
    func showErrorWithCancelAndRetry(_ error: Error, retry: @escaping ()->Void, cancel: @escaping () -> Void )
    func updateFromViewModel()
}

protocol ApplicationLetterViewModelProtocol : ApplicationLetterModelDelegate {
    var view: ApplicationLetterViewProtocol? { get set }
    var coordinator: ApplicationLetterViewControllerCoordinating? { get set }
    var model: ApplicationLetterModelProtocol { get }
    var applyButtonIsEnabled: Bool { get }
    var attributedText: NSAttributedString { get }
    func applyButtonWasTapped()
    func termsAndConditionsButtonWasTapped(sender: Any)
    func onViewDidLoad()
}

class ApplicationLetterViewModel : ApplicationLetterViewModelProtocol {

    var applyButtonIsEnabled: Bool { return model.allFieldsFilled }
    var attributedText: NSAttributedString { return model.letterString }
    let model: ApplicationLetterModelProtocol
    weak var coordinator: ApplicationLetterViewControllerCoordinating?
    weak var view: ApplicationLetterViewProtocol?
    
    init(letterModel: ApplicationLetterModelProtocol) {
        model = letterModel
    }
    
    func applyButtonWasTapped() {
        view?.isActivityIndicatorVisible = true
        coordinator?.continueApplicationWithCompletedLetter(sender: nil, completion: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.view?.isActivityIndicatorVisible = false
            if let error = error {
                strongSelf.view?.showErrorWithCancelAndRetry(error, retry: {
                    strongSelf.applyButtonWasTapped()
                },
                cancel: {})
                return
            }
        })
    }
    
    func termsAndConditionsButtonWasTapped(sender: Any) {
        coordinator?.termsAndConditionsWasTapped(sender: sender)
    }
    
    func onViewDidLoad() {
        model.render()
    }
}

extension ApplicationLetterViewModel : ApplicationLetterModelDelegate {
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, failedToSubmitLetter error: F4SNetworkError, retry: (() -> Void)?) {
        view?.showErrorWithCancelAndRetry(
            error,
            retry: { [weak self] in
                self?.model.render()
                retry?()
            },
            cancel: { [weak self] in
                self?.view?.isActivityIndicatorVisible = false
        })
    }
    
    func modelBusyState(_ model: ApplicationLetterModelProtocol, isBusy: Bool) {
        view?.isActivityIndicatorVisible = isBusy
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, stoppedProcessingWithError error: Error) {
        view?.showErrorWithCancelAndRetry(error, retry: { [weak self] in
            self?.model.render()
            },
            cancel: {})
    }
    
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, renderedTemplateToString: NSAttributedString, allFieldsFilled: Bool) {
        view?.updateFromViewModel()
    }
}
