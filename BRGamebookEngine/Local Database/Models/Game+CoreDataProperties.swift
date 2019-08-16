//
//  Game+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension Game {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var name: String
    @NSManaged public var uuid: UUID
    @NSManaged public var attributes: NSSet?
    @NSManaged public var pages: NSSet?
}

// MARK: Generated accessors for attributes

extension Game {
    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: Attribute)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: Attribute)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)
}

// MARK: Generated accessors for pages

extension Game {
    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: Page)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: Page)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)
}
