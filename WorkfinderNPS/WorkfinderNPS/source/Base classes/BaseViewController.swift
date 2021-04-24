//
//  BaseViewController.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class BaseViewController: UIViewController {
    var presenter: BasePresenter
    weak var coordinator: WorkfinderNPSCoordinator?
    
    var isFirst: Bool = false
    
    var onComplete: (() -> Void)?
    var onFinishNPS: (() -> Void)?
    var onCancelNPS: (() -> Void)?
    
    init(coordinator: WorkfinderNPSCoordinator, presenter: BasePresenter, onComplete: @escaping (() -> Void)) {
        self.coordinator = coordinator
        self.presenter = presenter
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        styleNavigationController()
        navigationController?.isNavigationBarHidden = false
        if isFirst {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTap))
        }
        
    }
    
    @objc func cancelButtonTap() {
        coordinator?.finishedNPS()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(vc: self)
        view.backgroundColor = UIColor.white
    }
}
