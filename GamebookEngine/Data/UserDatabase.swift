//
//  UserDatabase.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/26/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import UIKit

extension String {
    static let createdIntro = "createdIntro"
}

struct UserDatabase {
    static var standard: UserDefaults {
        let database = UserDefaults.standard
        return database
    }
}

extension UserDefaults {
    func createIntroGameIfNeeded() {
        let status: Bool = bool(forKey: .createdIntro)
        if !status {
            createDefaultGames()
            set(true, for: .createdIntro)
        }
    }

    func createDefaultGames() {
        if let introURL = Bundle.main.url(forResource: "An Introduction to Gamebook Engine", withExtension: "gbook"),
            let jsonData = try? Data(contentsOf: introURL) {
            GameSerializer.standard.gameFromJSONData(jsonData, alert: false)
        }
    }

    func createGameData(for game: Game) {
        guard let attributes = game.attributes?.allObjects as? [Attribute] else { return }
        for attribute in attributes {
            set(0, for: attribute.uuid.uuidString)
        }
    }

    func updateLastPage(for game: Game, to page: Page) {
        set(page.uuid.uuidString, for: game.uuid.uuidString)
    }

    func getLastPage(for game: Game, completion: @escaping (Page?) -> Void) {
        if let lastPageUUID = object(forKey: game.uuid.uuidString) as? String {
            GameDatabase.standard.fetchPage(by: lastPageUUID) { page in
                if let page = page {
                    completion(page)
                } else {
                    GameDatabase.standard.fetchFirstPage(for: game, completion: { page in
                        self.createGameData(for: game)
                        completion(page)
                    })
                }
            }
        } else {
            GameDatabase.standard.fetchFirstPage(for: game, completion: { page in
                self.createGameData(for: game)
                completion(page)
            })
        }
    }

    func updateAttributes(with consequences: [Consequence]) {
        for consequence in consequences {
            guard let attribute = consequence.attribute else { continue }
            var currentValue = float(forKey: attribute.uuid.uuidString)
            switch consequence.type {
            case .set:
                currentValue = Float(consequence.amount)
            case .add:
                currentValue += Float(consequence.amount)
            case .subtract:
                currentValue -= Float(consequence.amount)
            case .multiply:
                currentValue *= Float(consequence.amount)
            }
            set(currentValue, for: attribute.uuid.uuidString)
        }
    }

    func getCurrentAttributes(for game: Game) -> [UUID: Float] {
        var attrDict: [UUID: Float] = [:]
        guard let attributes = game.attributes?.allObjects as? [Attribute] else { return [:] }
        for attribute in attributes {
            attrDict[attribute.uuid] = float(forKey: attribute.uuid.uuidString)
        }
        return attrDict
    }
}

private extension UserDefaults {
    func set(_ object: Any?, for key: String) {
        set(object, forKey: key)
        synchronize()
    }
}
