//
//  ProjectApplyCoordinatorDelegate.swift
//  WorkfinderProjectApply
//
//  Created by Keith on 01/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderCoordinators

public protocol ProjectApplyCoordinatorDelegate: Coordinating {
    func onProjectApplyDidFinish()
}
