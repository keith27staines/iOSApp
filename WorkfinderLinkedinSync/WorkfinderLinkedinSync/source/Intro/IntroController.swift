//
//  IntroScreen.swift
//  WorkfinderLinkedinSync
//
//  Created by Keith on 14/06/2021.
//

import UIKit
import WorkfinderUI

class IntroController {
    
    weak var coordinator: IntroCoordinator?
    private let name: String
    
    init(coordinator: IntroCoordinator, name: String) {
        self.coordinator = coordinator
        self.name = name
    }
    
    func present() {
        coordinator?.router.present(sheet, animated: true, completion: nil)
    }
    
    private lazy var sheet: UIAlertController = {
        let sheet = UIAlertController(
            title: "Welcome, \(name)",
            message: "Set up your profile by connecting to your linkedin account or enter your details manually",
            preferredStyle: .actionSheet
        )
        
        let autoAction = UIAlertAction(title: "Sync with LinkedIn", style: .default) { [weak self] action in
            self?.coordinator?.introChoseAuto()
        }
        
        let manualAction = UIAlertAction(title: "Set up manually", style: .default) { [weak self] action in
            self?.coordinator?.introChoseManual()
        }
        
        let skipAction = UIAlertAction(title: "Skip for now", style: .cancel) { [weak self] action in
            self?.coordinator?.introChoseSkip()
        }
        sheet.addAction(autoAction)
        sheet.addAction(manualAction)
        sheet.addAction(skipAction)
        return sheet
    }()
}
