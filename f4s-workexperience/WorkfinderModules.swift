//
//  WorkfinderModules.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 09/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderNetworking
import WorkfinderCommon
import WorkfinderUI

struct WorkfinderModules {
    func assert() {
        print("\n-------- Begin WorkfinderModules checks --------")
        print(WorkfinderNetworking().sayHello(to: "Main"))
        print(WorkfinderCommon().sayHello(to: "Main"))
        print(WorkfinderUI().sayHello(to: "Main"))
        print("-------- End WorkfinderModules checks --------\n")
    }
}
