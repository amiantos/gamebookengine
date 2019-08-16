//
//  Rule+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

@objc public enum RuleType: Int32, CustomStringConvertible {
    case isEqualTo = 0
    case isNotEqualTo = 1
    case isGreaterThan = 2
    case isLessThan = 3

    public var description: String {
        switch self {
        case .isEqualTo: return "is equal to"
        case .isNotEqualTo: return "is not equal to"
        case .isGreaterThan: return "is greater than"
        case .isLessThan: return "is less than"
        }
    }

    public var jsonDescription: String {
        switch self {
        case .isEqualTo: return "equal"
        case .isNotEqualTo: return "not_equal"
        case .isGreaterThan: return "greater_than"
        case .isLessThan: return "less_than"
        }
    }

    init?(jsonDescription: String) {
        switch jsonDescription {
        case "equal":
            self.init(rawValue: 0)
        case "not_equal":
            self.init(rawValue: 1)
        case "greater_than":
            self.init(rawValue: 2)
        case "less_than":
            self.init(rawValue: 3)
        default:
            self.init(rawValue: 0)
        }
    }
}

extension Rule {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rule> {
        return NSFetchRequest<Rule>(entityName: "Rule")
    }

    @NSManaged public var type: RuleType
    @NSManaged public var uuid: UUID
    @NSManaged public var value: Float
    @NSManaged public var decision: Decision
    @NSManaged public var attribute: Attribute?
}

// MARK: Gamebook Engine Methods

extension Rule {
    public var hasIssues: Bool {
        guard attribute != nil else { return true }
        return false
    }
}
