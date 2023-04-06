//
//  Game+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/29/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

@objc public enum GameFont: Int32, CustomStringConvertible {
    case normal = 0
    case sansSerif = 1
    case serif = 2

    public var description: String {
        switch self {
        case .normal: return "Normal"
        case .sansSerif: return "Sans Serif"
        case .serif: return "Serif"
        }
    }

    public var jsonDescription: String {
        switch self {
        case .normal: return "normal"
        case .sansSerif: return "sans_serif"
        case .serif: return "serif"
        }
    }

    init?(jsonDescription: String) {
        switch jsonDescription {
        case "normal":
            self.init(rawValue: 0)
        case "sans_serif":
            self.init(rawValue: 1)
        case "serif":
            self.init(rawValue: 2)
        default:
            self.init(rawValue: 0)
        }
    }
}

public extension Game {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged var name: String
    @NSManaged var uuid: UUID
    @NSManaged var author: String
    @NSManaged var license: String?
    @NSManaged var website: URL?
    @NSManaged var about: String?
    @NSManaged var font: GameFont
    @NSManaged var attributes: NSSet?
    @NSManaged var pages: NSOrderedSet?
}

// MARK: Gamebook Engine Methods

extension Game {
    func createAttribute(_ name: String, completion: @escaping (Attribute?) -> Void) {
        GameDatabase.standard.createAttribute(for: self, name: name) { attribute in
            completion(attribute)
        }
    }
}

// MARK: Generated accessors for attributes

public extension Game {
    @objc(addAttributesObject:)
    @NSManaged func addToAttributes(_ value: Attribute)

    @objc(removeAttributesObject:)
    @NSManaged func removeFromAttributes(_ value: Attribute)

    @objc(addAttributes:)
    @NSManaged func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged func removeFromAttributes(_ values: NSSet)
}

// MARK: Generated accessors for pages

public extension Game {
    @objc(insertObject:inPagesAtIndex:)
    @NSManaged func insertIntoPages(_ value: Page, at idx: Int)

    @objc(removeObjectFromPagesAtIndex:)
    @NSManaged func removeFromPages(at idx: Int)

    @objc(insertPages:atIndexes:)
    @NSManaged func insertIntoPages(_ values: [Page], at indexes: NSIndexSet)

    @objc(removePagesAtIndexes:)
    @NSManaged func removeFromPages(at indexes: NSIndexSet)

    @objc(replaceObjectInPagesAtIndex:withObject:)
    @NSManaged func replacePages(at idx: Int, with value: Page)

    @objc(replacePagesAtIndexes:withPages:)
    @NSManaged func replacePages(at indexes: NSIndexSet, with values: [Page])

    @objc(addPagesObject:)
    @NSManaged func addToPages(_ value: Page)

    @objc(removePagesObject:)
    @NSManaged func removeFromPages(_ value: Page)

    @objc(addPages:)
    @NSManaged func addToPages(_ values: NSOrderedSet)

    @objc(removePages:)
    @NSManaged func removeFromPages(_ values: NSOrderedSet)
}
