//
//  Decision+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension Decision {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Decision> {
        return NSFetchRequest<Decision>(entityName: "Decision")
    }

    @NSManaged public var content: NSAttributedString
    @NSManaged public var uuid: UUID
    @NSManaged public var destination: Page?
    @NSManaged public var page: Page
}
