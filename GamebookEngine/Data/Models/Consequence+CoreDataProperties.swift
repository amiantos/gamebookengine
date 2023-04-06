//
//  Consequence+CoreDataProperties.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

@objc public enum ConsequenceType: Int32, CustomStringConvertible {
    case set = 0
    case add = 1
    case subtract = 2
    case multiply = 3

    public var description: String {
        switch self {
        case .set: return "Set"
        case .add: return "Add"
        case .subtract: return "Subtract"
        case .multiply: return "Multiply"
        }
    }

    public var jsonDescription: String {
        switch self {
        case .set: return "set"
        case .add: return "add"
        case .subtract: return "subtract"
        case .multiply: return "multiply"
        }
    }

    init?(jsonDescription: String) {
        switch jsonDescription {
        case "set":
            self.init(rawValue: 0)
        case "add":
            self.init(rawValue: 1)
        case "subtract":
            self.init(rawValue: 2)
        case "multiply":
            self.init(rawValue: 3)
        default:
            self.init(rawValue: 0)
        }
    }
}

public extension Consequence {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Consequence> {
        return NSFetchRequest<Consequence>(entityName: "Consequence")
    }

    @NSManaged var amount: Float
    @NSManaged var type: ConsequenceType
    @NSManaged var uuid: UUID?
    @NSManaged var attribute: Attribute?
    @NSManaged var page: Page?
}

// MARK: Gamebook Engine Methods

public extension Consequence {
    var hasIssues: Bool {
        guard attribute != nil else { return true }
        return false
    }
}
