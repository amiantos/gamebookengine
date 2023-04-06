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

public extension Attribute {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Attribute> {
        return NSFetchRequest<Attribute>(entityName: "Attribute")
    }

    @NSManaged var name: String
    @NSManaged var uuid: UUID
    @NSManaged var consequences: NSSet?
    @NSManaged var game: Game
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

public extension Attribute {
    @objc(addConsequencesObject:)
    @NSManaged func addToConsequences(_ value: Consequence)

    @objc(removeConsequencesObject:)
    @NSManaged func removeFromConsequences(_ value: Consequence)

    @objc(addConsequences:)
    @NSManaged func addToConsequences(_ values: NSSet)

    @objc(removeConsequences:)
    @NSManaged func removeFromConsequences(_ values: NSSet)
}
