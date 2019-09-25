//
//  ApplicationLetterModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 25/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

//import Foundation
import WorkfinderCommon

protocol ApplicationLetterModelProtocol {
    var letterString: NSAttributedString { get }
    var allFieldsFilled: Bool { get }
    var blanksModel: ApplicationLetterTemplateBlanksModelProtocol { get }
    var delegate: ApplicationLetterModelDelegate? { get set }
    func render()
}

protocol ApplicationLetterModelDelegate : class {
    func modelBusyState(_ model: ApplicationLetterModelProtocol, isBusy: Bool)
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, stoppedProcessingWithError: Error)
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, renderedTemplateToString: NSAttributedString, allFieldsFilled: Bool)
    func applicationLetterModel(_ model: ApplicationLetterModelProtocol, failedToSubmitLetter error: F4SNetworkError, retry: (()->Void)?)
}

class ApplicationLetterModel : ApplicationLetterModelProtocol {
    
    public var allFieldsFilled: Bool
    public var letterString: NSAttributedString
    public let templateService: F4STemplateServiceProtocol
    public let blanksModel: ApplicationLetterTemplateBlanksModelProtocol
    public weak var delegate: ApplicationLetterModelDelegate?
    var getTemplateAttempts = 0
    let textWhileBusy = NSAttributedString()
    let companyName: String

    private var busyCount = 0 {
        didSet {
            delegate?.modelBusyState(self, isBusy: busyCount > 0)
        }
    }
    
    public init(companyName: String,
                templateService: F4STemplateServiceProtocol,
                delegate: ApplicationLetterModelDelegate?,
                blanksModel: ApplicationLetterTemplateBlanksModelProtocol) {
        self.companyName = companyName
        self.letterString = textWhileBusy
        self.templateService = templateService
        self.delegate = delegate
        self.allFieldsFilled = false
        self.blanksModel = blanksModel
    }
    
    public func render() {
        letterString = textWhileBusy
        busyCount = 0
        getTemplateAttempts = 0
        getTemplate()
    }
    
    func getTemplate() {
        getTemplateAttempts += 1
        busyCount += 1
        if let template = blanksModel.template {
            handleTemplateLoadResult(result: F4SNetworkResult.success([template]))
            return
        }
        templateService.getTemplates { (result) in
            DispatchQueue.main.async { [weak self] in
                self?.handleTemplateLoadResult(result: result)
            }
        }
    }
    
    func handleTemplateLoadResult(result: F4SNetworkResult<[F4STemplate]>) {
        switch result {
        case .error(let error):
            if error.retry && getTemplateAttempts < 3 {
                getTemplate()
            } else {
                delegate?.applicationLetterModel(self, stoppedProcessingWithError: error)
                busyCount = 0
            }
        case .success(let templates):
            guard let template = templates.first else {
                let noTemplateError = F4SNetworkError(localizedDescription: "No template avaialable", attempting: "load template", retry: false)
                delegate?.applicationLetterModel(self, stoppedProcessingWithError: noTemplateError)
                busyCount = 0
                return
            }
            blanksModel.setTemplate(template)
            renderTemplate(template)
        }
    }
    
    func renderTemplate(_ template: F4STemplate?) {
        guard let template = template else { return }
        let renderer = ApplicationLetterTemplateRenderer(
            currentTemplate: template,
            companyName: companyName,
            selectedTemplateChoices: blanksModel.populatedBlanks())
        
        do {
            let letterText = try renderer.renderTemplateToPlainString()
            allFieldsFilled = renderer.isComplete
            letterString = ApplicationLetterTextDecorator().decorateLetterText(letterText)
            delegate?.applicationLetterModel(self, renderedTemplateToString: letterString, allFieldsFilled: allFieldsFilled)
        } catch {
            allFieldsFilled = false
            delegate?.applicationLetterModel(self, stoppedProcessingWithError: error)
        }
        busyCount = 0
    }
}


