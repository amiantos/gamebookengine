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

@objc public enum MatchType: Int32, CustomStringConvertible {
    case matchAll = 0
    case matchAny = 1

    public var description: String {
        switch self {
        case .matchAll: return "All"
        case .matchAny: return "Any"
        }
    }

    public var jsonDescription: String {
        switch self {
        case .matchAll: return "match_all"
        case .matchAny: return "match_any"
        }
    }
}

public extension Decision {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Decision> {
        return NSFetchRequest<Decision>(entityName: "Decision")
    }

    @NSManaged var content: String
    @NSManaged var uuid: UUID
    @NSManaged var destination: Page?
    @NSManaged var page: Page
    @NSManaged var matchStyle: MatchType
    @NSManaged var rules: NSSet?
}

// MARK: Gamebook Engine Methods

public extension Decision {
    var hasIssues: Bool {
        guard let destination = destination else { return true }
        if let rules = rules?.allObjects as? [Rule] {
            for rule in rules where rule.hasIssues {
                return true
            }
        }
        return destination.content.isEmpty
    }
}
