//
//  GameSerializer.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/27/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import UIKit

class GameSerializer {
    static let standard: GameSerializer = .init()

    // MARK: - Game

    func gameFromJSONData(_ jsonData: Data, alert: Bool = true) {
        // Create game
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let gameStruct = try decoder.decode(GameStruct.self, from: jsonData)

            if alert {
                let alert = UIAlertController.createCancelableAlert(
                    title: "Import \"\(gameStruct.name)\"?",
                    message: "Are you sure you want to import this game?",
                    primaryActionTitle: "Import"
                ) { _ in
                    GameDatabase.standard.createGame(from: gameStruct) { game in
                        if let newGame = game {
                            let alert = UIAlertController(
                                title: "Success!",
                                message: "The game \"\(newGame.name)\" was imported successfully",
                                preferredStyle: .alert
                            )
                            let alertButton = UIAlertAction(title: "Groovy", style: .default, handler: nil)
                            alert.addAction(alertButton)
                            DispatchQueue.main.async {
                                if let appDelegate = UIApplication.shared.delegate,
                                   let appWindow = appDelegate.window!,
                                   let rootViewController = appWindow.rootViewController
                                {
                                    rootViewController.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate,
                       let appWindow = appDelegate.window!,
                       let rootViewController = appWindow.rootViewController
                    {
                        rootViewController.present(alert, animated: true, completion: nil)
                        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
                    }
                }
            } else {
                GameDatabase.standard.createGame(from: gameStruct) { _ in
                    // Do nothing
                }
            }
        } catch {
            let alert = UIAlertController(
                title: "Failure!",
                message: "This game could not be imported, either because it's not in the correct format, or for some other unknown reason.",
                preferredStyle: .alert
            )
            let alertButton = UIAlertAction(title: "Oh, okay", style: .default, handler: nil)
            alert.addAction(alertButton)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate,
                   let appWindow = appDelegate.window!,
                   let rootViewController = appWindow.rootViewController
                {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func toJSONString(game: Game) -> String {
        let dictionary = toDictionary(game: game)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            if let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String? {
                return jsonString
            }
        } catch {
            fatalError()
        }
        return ""
    }

    func toDictionary(game: Game) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["uuid"] = game.uuid.uuidString
        dictionary["name"] = game.name
        dictionary["author"] = game.author
        dictionary["about"] = game.about
        dictionary["website"] = game.website?.absoluteString
        dictionary["license"] = game.license
        dictionary["font"] = game.font.jsonDescription
        if let attributes = game.attributes?.allObjects as? [Attribute] {
            dictionary["attributes"] = toDictionary(attributes: attributes)
        }
        if let pages = game.pages?.array as? [Page] {
            dictionary["pages"] = toDictionary(pages: pages)
        }
        return dictionary
    }

    // MARK: - Pages

    func toDictionary(pages: [Page]) -> [[String: Any]] {
        var array: [[String: Any]] = []
        for page in pages {
            if (page.origins?.count ?? 0) > 0 || page.type == .first {
                array.append(toDictionary(page: page))
            }
        }
        return array
    }

    func toDictionary(page: Page) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["uuid"] = page.uuid.uuidString
        dictionary["content"] = page.content
        dictionary["type"] = page.type.jsonDescription
        if let consequences = page.consequences?.allObjects as? [Consequence], !consequences.isEmpty {
            dictionary["consequences"] = toDictionary(consequences: consequences)
        }
        if let decisions = page.decisions?.array as? [Decision], !decisions.isEmpty {
            dictionary["decisions"] = toDictionary(decisions: decisions)
        }
        return dictionary
    }

    // MARK: - Consequences

    func toDictionary(consequences: [Consequence]) -> [[String: Any]] {
        var array: [[String: Any]] = []
        for consequence in consequences {
            array.append(toDictionary(consequence: consequence))
        }
        return array
    }

    func toDictionary(consequence: Consequence) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["uuid"] = consequence.uuid?.uuidString
        dictionary["type"] = consequence.type.jsonDescription
        dictionary["amount"] = consequence.amount
        if let attribute = consequence.attribute {
            dictionary["attribute_uuid"] = attribute.uuid.uuidString
        }
        return dictionary
    }

    // MARK: - Decisions

    func toDictionary(decisions: [Decision]) -> [[String: Any]] {
        var array: [[String: Any]] = []
        for decision in decisions {
            array.append(toDictionary(decision: decision))
        }
        return array
    }

    func toDictionary(decision: Decision) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["uuid"] = decision.uuid.uuidString
        dictionary["content"] = decision.content
        dictionary["match_style"] = decision.matchStyle.jsonDescription
        dictionary["destination_uuid"] = decision.destination?.uuid.uuidString
        if let rules = decision.rules?.allObjects as? [Rule] {
            dictionary["rules"] = toDictionary(rules: rules)
        }
        return dictionary
    }

    // MARK: - Rules

    func toDictionary(rules: [Rule]) -> [[String: Any]] {
        var array: [[String: Any]] = []
        for rule in rules {
            array.append(toDictionary(rule: rule))
        }
        return array
    }

    func toDictionary(rule: Rule) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["uuid"] = rule.uuid.uuidString
        dictionary["type"] = rule.type.jsonDescription
        dictionary["value"] = rule.value
        if let attribute = rule.attribute {
            dictionary["attribute_uuid"] = attribute.uuid.uuidString
        }
        return dictionary
    }

    // MARK: - Attributes

    func toDictionary(attributes: [Attribute]) -> [[String: Any]] {
        var attributeArray: [[String: Any]] = []
        for attribute in attributes {
            attributeArray.append(toDictionary(attribute: attribute))
        }
        return attributeArray
    }

    func toDictionary(attribute: Attribute) -> [String: Any] {
        var attributeDictionary: [String: Any] = [:]
        attributeDictionary["uuid"] = attribute.uuid.uuidString
        attributeDictionary["name"] = attribute.name
        return attributeDictionary
    }

    // MARK: - HTML Export

    func toHTMLFile(game: Game) -> String? {
        // Load the HTML template from the bundle
        guard let templateURL = Bundle.main.url(forResource: "index", withExtension: "html"),
              let templateHTML = try? String(contentsOf: templateURL, encoding: .utf8) else {
            Log.error("Could not load webplayer/index.html template")
            return nil
        }

        // Get the game JSON
        let gameJSON = toJSONString(game: game)

        // Create the injection script that will:
        // 1. Auto-load the game on page load
        // 2. Hide the "Load Different Game" button
        let injectionScript = """
        <script>
        // Auto-load embedded game
        window.EMBEDDED_GAME_DATA = \(gameJSON);

        // Initialize player globally before DOMContentLoaded
        window.player = null;

        document.addEventListener('DOMContentLoaded', function() {
            if (window.EMBEDDED_GAME_DATA) {
                try {
                    const game = window.EMBEDDED_GAME_DATA;
                    // Create player instance and make it globally accessible
                    window.player = new GamePlayer();
                    window.player.loadGame(game);

                    // Hide the "Load Different Game" button
                    setTimeout(function() {
                        const buttons = document.querySelectorAll('.btn');
                        buttons.forEach(function(btn) {
                            if (btn.textContent.includes('Load Different Game')) {
                                btn.style.display = 'none';
                            }
                        });
                    }, 100);
                } catch (error) {
                    console.error('Failed to load embedded game:', error);
                    showError('Failed to load the embedded game: ' + error.message);
                }
            }
        });
        </script>
        """

        // Insert the script before the closing </body> tag
        guard let bodyCloseRange = templateHTML.range(of: "</body>", options: .backwards) else {
            Log.error("Could not find </body> tag in template")
            return nil
        }

        var modifiedHTML = templateHTML
        modifiedHTML.insert(contentsOf: injectionScript, at: bodyCloseRange.lowerBound)

        return modifiedHTML
    }
}
