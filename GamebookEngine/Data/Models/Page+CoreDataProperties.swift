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

extension Page {
    public override var description: String { return "\(uuid.uuidString)" }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged public var content: String
    @NSManaged public var type: PageType
    @NSManaged public var uuid: UUID
    @NSManaged public var consequences: NSSet?
    @NSManaged public var decisions: NSOrderedSet?
    @NSManaged public var game: Game
    @NSManaged public var origins: NSSet?
}

// MARK: Gamebook Engine Methods

extension Page {
    // MARK: Updates

    public func setContent(to content: String) {
        self.content = content
        GameDatabase.standard.saveContext()
    }

    public func setType(to type: PageType) {
        self.type = type
        if type == .ending {
            // Remove all decisions and consequences
            if let decisions = self.decisions?.array as? [Decision] {
                for decision in decisions {
                    GameDatabase.standard.delete(decision)
                }
            }
            if let consequences = self.consequences?.allObjects as? [Consequence] {
                for consequence in consequences {
                    GameDatabase.standard.delete(consequence)
                }
            }
        }
        GameDatabase.standard.saveContext()
    }

    // MARK: Issue Detection

    public var hasIssues: Bool {
        if needsDecisions {
            return true
        } else if hasDecisionsWithIssues {
            return true
        } else if hasConsequencesWithIssues {
            return true
        }
        return false
    }

    public var needsDecisions: Bool {
        let decisionCount = decisions?.count ?? 0
        if decisionCount == 0, type != .ending {
            return true
        }
        return false
    }

    public var hasDecisionsWithIssues: Bool {
        guard let decisions = self.decisions?.array as? [Decision] else { return false }
        for decision in decisions where decision.hasIssues {
            return true
        }
        return false
    }

    public var hasConsequencesWithIssues: Bool {
        guard let consequences = self.consequences?.allObjects as? [Consequence] else { return false }
        for consequence in consequences where consequence.hasIssues {
            return true
        }
        return false
    }
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
    @objc(insertObject:inDecisionsAtIndex:)
    @NSManaged public func insertIntoDecisions(_ value: Decision, at idx: Int)

    @objc(removeObjectFromDecisionsAtIndex:)
    @NSManaged public func removeFromDecisions(at idx: Int)

    @objc(insertDecisions:atIndexes:)
    @NSManaged public func insertIntoDecisions(_ values: [Decision], at indexes: NSIndexSet)

    @objc(removeDecisionsAtIndexes:)
    @NSManaged public func removeFromDecisions(at indexes: NSIndexSet)

    @objc(replaceObjectInDecisionsAtIndex:withObject:)
    @NSManaged public func replaceDecisions(at idx: Int, with value: Decision)

    @objc(replaceDecisionsAtIndexes:withDecisions:)
    @NSManaged public func replaceDecisions(at indexes: NSIndexSet, with values: [Decision])

    @objc(addDecisionsObject:)
    @NSManaged public func addToDecisions(_ value: Decision)

    @objc(removeDecisionsObject:)
    @NSManaged public func removeFromDecisions(_ value: Decision)

    @objc(addDecisions:)
    @NSManaged public func addToDecisions(_ values: NSOrderedSet)

    @objc(removeDecisions:)
    @NSManaged public func removeFromDecisions(_ values: NSOrderedSet)
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
