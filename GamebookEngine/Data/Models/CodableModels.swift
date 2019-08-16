//
//  CodableModels.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation

struct GameStruct: Codable {
    let uuid: UUID
    let name: String
    let author: String?
    let about: String?
    let license: String?
    let font: String
    let website: URL?
    let pages: [PageStruct]
    let attributes: [AttributeStruct]
}

struct AttributeStruct: Codable {
    let uuid: UUID
    let name: String
}

struct PageStruct: Codable {
    let uuid: UUID
    let type: String
    let content: String
    let consequences: [ConsequenceStruct]?
    let decisions: [DecisionStruct]?
}

struct DecisionStruct: Codable {
    let uuid: UUID
    let content: String
    let destinationUuid: UUID?
    let rules: [RuleStruct]?
    let matchStyle: String
}

struct ConsequenceStruct: Codable {
    let uuid: UUID
    let type: String
    let amount: Float
    let attributeUuid: UUID?
}

struct RuleStruct: Codable {
    let uuid: UUID
    let type: String
    let value: Float
    let attributeUuid: UUID?
}
