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
    
    var onComplete: (() -> Void)?
    var onFinishNPS: (() -> Void)?
    var onCancelNPS: (() -> Void)?
    
    init(coordinator: WorkfinderNPSCoordinator, presenter: BasePresenter, onComplete: @escaping (() -> Void)) {
        self.coordinator = coordinator
        self.presenter = presenter
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        presenter.onViewDidLoad(vc: self)
    }
}
