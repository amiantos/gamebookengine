//
//  GamePlayer.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 9/15/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation

protocol GamePlayerDelegate: AnyObject {
    func loadPage()
}

class GamePlayer: GamePlayerDelegate {
    fileprivate var game: Game
    fileprivate var page: Page?
    fileprivate(set) var decisions: [Decision] = []

    weak var delegate: GamePlayerDelegate?

    // MARK: Initialization

    init(for game: Game) {
        Log.debug("New player created for game: '\(game.name)'")
        self.game = game
    }

    // MARK: Game Playback Controls

    func loadGame() {
        Log.debug("Loading game.")
        UserDatabase.standard.getLastPage(for: game) { page in
            guard let page = page else { fatalError() }
            self.page = page
            self.loadPage()
        }
    }

    func restartGame() {
        Log.debug("Restarting game.")
        UserDatabase.standard.createGameData(for: game)
        GameDatabase.standard.fetchFirstPage(for: game) { page in
            guard let page = page else { fatalError() }
            self.page = page
            self.loadPage()
        }
    }

    func pickedDecision(at index: Int) {
        guard let decision = decisions.item(at: index),
              let page = decision.destination else { return }
        self.page = page
        loadPage()
    }

    // MARK: Page Content

    func getPageAttributedString() -> NSAttributedString {
        guard let page = page else { fatalError() }
        return BRMarkdownParser.standard.convertToAttributedString(page.content, with: game.font)
    }

    func getFont() -> GameFont {
        return game.font
    }

    // MARK: Processing

    internal func loadPage() {
        guard let page = page else { return }
        loadConsequences()
        loadDecisions()
        UserDatabase.standard.updateLastPage(for: game, to: page)
        delegate?.loadPage()
    }

    private func loadConsequences() {
        if let consequences = page?.consequences?.allObjects as? [Consequence] {
            UserDatabase.standard.updateAttributes(with: consequences)
        }
    }

    private func loadDecisions() {
        decisions = []
        if let decisions = page?.decisions?.array as? [Decision] {
            let currentValues = UserDatabase.standard.getCurrentAttributes(for: game)
            for decision in decisions {
                if let rules = decision.rules?.allObjects as? [Rule], !rules.isEmpty {
                    var passOrFail: [Bool] = []
                    for rule in rules {
                        guard let ruleAttributeUUID = rule.attribute?.uuid else { continue }
                        var pass = false
                        switch rule.type {
                        case .isEqualTo:
                            pass = Float(rule.value) == currentValues[ruleAttributeUUID] ? true : false
                        case .isNotEqualTo:
                            pass = Float(rule.value) != currentValues[ruleAttributeUUID] ? true : false
                        case .isGreaterThan:
                            pass = Float(rule.value) < Float(currentValues[ruleAttributeUUID]!) ? true : false
                        case .isLessThan:
                            pass = Float(rule.value) > Float(currentValues[ruleAttributeUUID]!) ? true : false
                        }
                        passOrFail.append(pass)
                    }
                    switch decision.matchStyle {
                    case .matchAll:
                        var failure = false
                        for passState in passOrFail where passState == false {
                            failure = true
                            break
                        }
                        if !failure {
                            self.decisions.append(decision)
                        }
                    case .matchAny:
                        for passState in passOrFail where passState == true {
                            self.decisions.append(decision)
                            break
                        }
                    }
                } else {
                    self.decisions.append(decision)
                }
            }
        }
    }
}
