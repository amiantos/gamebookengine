//
//  Page+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/27/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

@objc public enum PageType: Int32, CustomStringConvertible {
    case none = 0
    case first = 1
    case ending = 2

    public var description: String {
        switch self {
        case .none: return "None"
        case .first: return "First"
        case .ending: return "Ending"
        }
    }

    public var jsonDescription: String {
        switch self {
        case .none: return ""
        case .first: return "first"
        case .ending: return "ending"
        }
    }

    init?(jsonDescription: String) {
        switch jsonDescription {
        case "first":
            self.init(rawValue: 1)
        case "ending":
            self.init(rawValue: 2)
        default:
            self.init(rawValue: 0)
        }
    }
}

public extension Page {
    override var description: String { return "\(uuid.uuidString)" }

    @nonobjc class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged var content: String
    @NSManaged var type: PageType
    @NSManaged var uuid: UUID
    @NSManaged var consequences: NSSet?
    @NSManaged var decisions: NSOrderedSet?
    @NSManaged var game: Game
    @NSManaged var origins: NSSet?
}

// MARK: Gamebook Engine Methods

public extension Page {
    // MARK: Updates

    func setContent(to content: String) {
        self.content = content
        GameDatabase.standard.saveContext()
    }

    func setType(to type: PageType) {
        self.type = type
        if type == .ending {
            // Remove all decisions and consequences
            if let decisions = decisions?.array as? [Decision] {
                for decision in decisions {
                    GameDatabase.standard.delete(decision)
                }
            }
            if let consequences = consequences?.allObjects as? [Consequence] {
                for consequence in consequences {
                    GameDatabase.standard.delete(consequence)
                }
            }
        }
        GameDatabase.standard.saveContext()
    }

    // MARK: Issue Detection

    var hasIssues: Bool {
        if needsDecisions {
            return true
        } else if hasDecisionsWithIssues {
            return true
        } else if hasConsequencesWithIssues {
            return true
        }
        return false
    }

    var needsDecisions: Bool {
        let decisionCount = decisions?.count ?? 0
        if decisionCount == 0, type != .ending {
            return true
        }
        return false
    }

    var hasDecisionsWithIssues: Bool {
        guard let decisions = decisions?.array as? [Decision] else { return false }
        for decision in decisions where decision.hasIssues {
            return true
        }
        return false
    }

    var hasConsequencesWithIssues: Bool {
        guard let consequences = consequences?.allObjects as? [Consequence] else { return false }
        for consequence in consequences where consequence.hasIssues {
            return true
        }
        return false
    }
}

// MARK: Generated accessors for consequences

public extension Page {
    @objc(addConsequencesObject:)
    @NSManaged func addToConsequences(_ value: Consequence)

    @objc(removeConsequencesObject:)
    @NSManaged func removeFromConsequences(_ value: Consequence)

    @objc(addConsequences:)
    @NSManaged func addToConsequences(_ values: NSSet)

    @objc(removeConsequences:)
    @NSManaged func removeFromConsequences(_ values: NSSet)
}

// MARK: Generated accessors for decisions

public extension Page {
    @objc(insertObject:inDecisionsAtIndex:)
    @NSManaged func insertIntoDecisions(_ value: Decision, at idx: Int)

    @objc(removeObjectFromDecisionsAtIndex:)
    @NSManaged func removeFromDecisions(at idx: Int)

    @objc(insertDecisions:atIndexes:)
    @NSManaged func insertIntoDecisions(_ values: [Decision], at indexes: NSIndexSet)

    @objc(removeDecisionsAtIndexes:)
    @NSManaged func removeFromDecisions(at indexes: NSIndexSet)

    @objc(replaceObjectInDecisionsAtIndex:withObject:)
    @NSManaged func replaceDecisions(at idx: Int, with value: Decision)

    @objc(replaceDecisionsAtIndexes:withDecisions:)
    @NSManaged func replaceDecisions(at indexes: NSIndexSet, with values: [Decision])

    @objc(addDecisionsObject:)
    @NSManaged func addToDecisions(_ value: Decision)

    @objc(removeDecisionsObject:)
    @NSManaged func removeFromDecisions(_ value: Decision)

    @objc(addDecisions:)
    @NSManaged func addToDecisions(_ values: NSOrderedSet)

    @objc(removeDecisions:)
    @NSManaged func removeFromDecisions(_ values: NSOrderedSet)
}

// MARK: Generated accessors for origins

public extension Page {
    @objc(addOriginsObject:)
    @NSManaged func addToOrigins(_ value: Decision)

    @objc(removeOriginsObject:)
    @NSManaged func removeFromOrigins(_ value: Decision)

    @objc(addOrigins:)
    @NSManaged func addToOrigins(_ values: NSSet)

    @objc(removeOrigins:)
    @NSManaged func removeFromOrigins(_ values: NSSet)
}
