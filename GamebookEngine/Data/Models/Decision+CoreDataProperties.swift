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

extension Decision {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Decision> {
        return NSFetchRequest<Decision>(entityName: "Decision")
    }

    @NSManaged public var content: String
    @NSManaged public var uuid: UUID
    @NSManaged public var destination: Page?
    @NSManaged public var page: Page
    @NSManaged public var matchStyle: MatchType
    @NSManaged public var rules: NSSet?
}

// MARK: Gamebook Engine Methods

extension Decision {
    public var hasIssues: Bool {
        guard let destination = self.destination else { return true }
        if let rules = self.rules?.allObjects as? [Rule] {
            for rule in rules where rule.hasIssues {
                return true
            }
        }
        return destination.content.isEmpty
    }
}
