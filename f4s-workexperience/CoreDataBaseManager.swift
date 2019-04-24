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
import XCGLogger

class CoreDataBaseManager {
    
    public init() {
        
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    func save() {
        try! managedObjectContext.save()
    }
}
