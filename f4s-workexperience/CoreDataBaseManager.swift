//
//  CoreDataBaseManager.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataBaseManager {
    
    public init() {
        
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.managedObjectContext
        return managedObjectContext
    }()

    func save() {
        do {
            try managedObjectContext?.save()
        } catch _ {
        }
    }
}
