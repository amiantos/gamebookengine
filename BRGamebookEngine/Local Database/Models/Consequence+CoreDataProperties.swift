//
//  Consequence+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData

@objc public enum ConsequenceType: Int32 {
    case set = 0
    case add = 1
    case subtract = 2
    case multiply = 3
}

extension Consequence {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Consequence> {
        return NSFetchRequest<Consequence>(entityName: "Consequence")
    }

    @NSManaged public var amount: Int32
    @NSManaged public var type: ConsequenceType
    @NSManaged public var uuid: UUID?
    @NSManaged public var attribute: Attribute?
    @NSManaged public var page: Page?

}
