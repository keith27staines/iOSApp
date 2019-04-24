//
//  F4SPostDocumentDataViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 12/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

protocol PostDocumentsWithDataViewControllerDelegate {
    func postDocumentsControllerDidCancel(_ controller: PostDocumentsWithDataViewController)
    func postDocumentsControllerDidCompleteUpload(_ controller: PostDocumentsWithDataViewController)
}

class PostDocumentsWithDataViewController : UIViewController {
    var documentModel: F4SDocumentUploadModelBase?
    
    var delegate: PostDocumentsWithDataViewControllerDelegate? = nil
    var currentDocumentIndex: Int? = 0
    
    var cancelled: Bool = false
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var stateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress = 0.0
        return progressView
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, progressBar, stateLabel])
        stack.alignment = .fill
        stack.spacing = 20
        stack.axis = .vertical
        return stack
    }()
    
    func cancel() {
        cancelled = true
        currentUpload?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        applyStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.uploadNextDocument()
        }
    }
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: retryButton)
    }
    
    func configureViews() {
        navigationItem.title = "Document upload"
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20).isActive = true
        stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 60).isActive = true
        stack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -20).isActive = true
        stack.bottomAnchor.constraint(lessThanOrEqualTo:view.layoutMarginsGuide.bottomAnchor, constant: -100).isActive = true
    }
    
    lazy var retryButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Retry", for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.leftAnchor.constraint(equalTo: stack.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: stack.rightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        button.addTarget(self, action: #selector(uploadNextDocument), for: .touchUpInside)
        return button
    }()
    
    var currentUpload: F4SDocumentUploader? = nil
    
    @objc func handleCancel() {
        cancel()
        delegate?.postDocumentsControllerDidCancel(self)
    }
    
    lazy var numberToUpload: Int = {
       return documentModel?.documentsWithData().count ?? 0
    }()
    var numberUploaded = 0
    
    func updateUploadCount() {
        title = "Upload \(numberUploaded+1)/\(numberToUpload)"
    }
    
    @objc func uploadNextDocument() {
        retryButton.isHidden = true
        guard cancelled == false else {
            delegate?.postDocumentsControllerDidCancel(self)
            return
        }
        guard let document = documentModel?.documentsWithData().first else {
            delegate?.postDocumentsControllerDidCompleteUpload(self)
            return
        }
        guard let placementUuid = documentModel?.documentService?.placementUuid,
            let uploader = F4SDocumentUploader(document: document, placementUuid: placementUuid)
            else { return }
        updateUploadCount()
        nameLabel.text = "Uploading \"\(document.name ?? "...")\""
        uploader.delegate = self
        currentUpload = uploader
        uploader.resume()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
    }
}

extension PostDocumentsWithDataViewController : F4SDocumentUploaderDelegate {
    func documentUploader(_ uploader: F4SDocumentUploader, didChangeState state: F4SDocumentUploader.State) {
        retryButton.isHidden = true
        switch uploader.state {
        case .waiting:
            stateLabel.text = "Waiting for connection"
        case .uploading(let fraction):
            progressBar.progress = fraction
            stateLabel.text = "\(Int(fraction * 100))%"
        case .completed:
            stateLabel.text = "Document uploaded"
            numberUploaded += 1
            uploadNextDocument()
        case .cancelled:
            progressBar.progress = 0
            stateLabel.text = "Operation cancelled"
        case .paused(let fraction):
            progressBar.progress = fraction
            stateLabel.text = "Paused at \(Int(fraction * 100))%"
        case .failed(let error):
            progressBar.progress = 0
            retryButton.isHidden = false
            stateLabel.text = error.localizedDescription
        }
    }
}
