//
//  Notes.swift
//  Notes-Swift
//
//  Created by Aayush Maheshwari on 17/04/19.
//  Copyright © 2019 aayush. All rights reserved.
//

import UIKit
import CoreData

public class Notes: NSManagedObject {
    @NSManaged public var content : String
    @NSManaged public var title : String
    @NSManaged public var longitude : Double
    @NSManaged public var latitude : Double
}

extension Notes {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }
}
