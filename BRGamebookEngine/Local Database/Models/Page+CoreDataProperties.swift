//
//  Page+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData

extension Page {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged public var content: NSAttributedString?
    @NSManaged public var type: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var consequences: NSSet?
    @NSManaged public var decisions: NSSet?
    @NSManaged public var game: Game?
    @NSManaged public var origins: NSSet?

}

// MARK: Generated accessors for consequences
extension Page {

    @objc(addConsequencesObject:)
    @NSManaged public func addToConsequences(_ value: Consequence)

    @objc(removeConsequencesObject:)
    @NSManaged public func removeFromConsequences(_ value: Consequence)

    @objc(addConsequences:)
    @NSManaged public func addToConsequences(_ values: NSSet)

    @objc(removeConsequences:)
    @NSManaged public func removeFromConsequences(_ values: NSSet)

}

// MARK: Generated accessors for decisions
extension Page {

    @objc(addDecisionsObject:)
    @NSManaged public func addToDecisions(_ value: Decision)

    @objc(removeDecisionsObject:)
    @NSManaged public func removeFromDecisions(_ value: Decision)

    @objc(addDecisions:)
    @NSManaged public func addToDecisions(_ values: NSSet)

    @objc(removeDecisions:)
    @NSManaged public func removeFromDecisions(_ values: NSSet)

}

// MARK: Generated accessors for origins
extension Page {

    @objc(addOriginsObject:)
    @NSManaged public func addToOrigins(_ value: Decision)

    @objc(removeOriginsObject:)
    @NSManaged public func removeFromOrigins(_ value: Decision)

    @objc(addOrigins:)
    @NSManaged public func addToOrigins(_ values: NSSet)

    @objc(removeOrigins:)
    @NSManaged public func removeFromOrigins(_ values: NSSet)

}
