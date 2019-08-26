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
}

extension Rule {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rule> {
        return NSFetchRequest<Rule>(entityName: "Rule")
    }

    @NSManaged public var type: RuleType
    @NSManaged public var uuid: UUID
    @NSManaged public var value: Int32
    @NSManaged public var decision: Decision
    @NSManaged public var attribute: Attribute?
}
