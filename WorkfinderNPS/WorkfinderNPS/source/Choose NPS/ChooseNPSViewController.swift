//
//  ChooseNPS.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class ChooseNPSViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Choose"
        view.addSubview(scoreView)
        let guide = view.safeAreaLayoutGuide
        scoreView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: guide.trailingAnchor)
    }
    
    lazy var scoreView = NPSScoreView()

    
}
