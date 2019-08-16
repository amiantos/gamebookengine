//
//  Attribute+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension Attribute {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attribute> {
        return NSFetchRequest<Attribute>(entityName: "Attribute")
    }

    @NSManaged public var name: String
    @NSManaged public var uuid: UUID
    @NSManaged public var consequences: NSSet?
    @NSManaged public var game: Game
}

// MARK: Gamebook Engine Methods

extension Attribute {
    func delete(completion: @escaping (Attribute?) -> Void) {
        GameDatabase.standard.deleteAttribute(self) { attribute in
            completion(attribute)
        }
    }
}

// MARK: Generated accessors for consequences

extension Attribute {
    @objc(addConsequencesObject:)
    @NSManaged public func addToConsequences(_ value: Consequence)

    @objc(removeConsequencesObject:)
    @NSManaged public func removeFromConsequences(_ value: Consequence)

    @objc(addConsequences:)
    @NSManaged public func addToConsequences(_ values: NSSet)

    @objc(removeConsequences:)
    @NSManaged public func removeFromConsequences(_ values: NSSet)
}
