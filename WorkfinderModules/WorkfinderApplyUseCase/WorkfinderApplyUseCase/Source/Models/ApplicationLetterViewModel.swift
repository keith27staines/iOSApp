//
//  ApplicationLetterViewModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public protocol ApplicationLetterViewProtocol : class {
    var isActivityIndicatorVisible: Bool { get set }
    func showErrorWithCancelAndRetry(_ error: Error, retry: @escaping ()->Void, cancel: @escaping () -> Void )
    func updateFromViewModel()
}

public protocol ApplicationLetterViewModelProtocol : ApplicationLetterModelDelegate {
    var view: ApplicationLetterViewProtocol? { get set }
    var coordinator: ApplicationLetterViewControllerCoordinating? { get set }
    var model: ApplicationLetterModelProtocol { get }
    var applyButtonIsEnabled: Bool { get }
    var attributedText: NSAttributedString { get }
    func applyButtonWasTapped()
    func termsAndConditionsButtonWasTapped(sender: Any)
    func onViewDidLoad()
}

public class ApplicationLetterViewModel : ApplicationLetterViewModelProtocol {

    public var applyButtonIsEnabled: Bool { return model.allFieldsFilled }
    public var attributedText: NSAttributedString { return model.letterString }
    public let model: ApplicationLetterModelProtocol
    public weak var coordinator: ApplicationLetterViewControllerCoordinating?
    public weak var view: ApplicationLetterViewProtocol?
    
    public init(letterModel: ApplicationLetterModelProtocol) {
        model = letterModel
    }
    
    public func applyButtonWasTapped() {
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
    
    public func termsAndConditionsButtonWasTapped(sender: Any) {
        coordinator?.termsAndConditionsWasTapped(sender: sender)
    }
    
    public func onViewDidLoad() {
        model.render()
    }
}

extension ApplicationLetterViewModel : ApplicationLetterModelDelegate {
    public func applicationLetterModel(_ model: ApplicationLetterModelProtocol, failedToSubmitLetter error: WEXError, retry: (() -> Void)?) {
        view?.showErrorWithCancelAndRetry(
            error,
            retry: { [weak self] in
                self?.model.render()
                retry?()
            },
            cancel: {})
    }
    
    public func modelBusyState(_ model: ApplicationLetterModelProtocol, isBusy: Bool) {
        view?.isActivityIndicatorVisible = isBusy
    }
    
    public func applicationLetterModel(_ model: ApplicationLetterModelProtocol, stoppedProcessingWithError error: Error) {
        view?.showErrorWithCancelAndRetry(error, retry: { [weak self] in
            self?.model.render()
            },
            cancel: {})
    }
    
    public func applicationLetterModel(_ model: ApplicationLetterModelProtocol, renderedTemplateToString: NSAttributedString, allFieldsFilled: Bool) {
        view?.updateFromViewModel()
    }
}
