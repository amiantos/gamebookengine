//
//  GameDatabase.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class GameDatabase {
    static let standard: GameDatabase = GameDatabase()

    var mainManagedObjectContext: NSManagedObjectContext
    var persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = {
            let container = NSPersistentContainer(name: "BRGamebookEngine")
            container.loadPersistentStores(completionHandler: { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        mainManagedObjectContext = persistentContainer.viewContext
    }

    deinit {
        self.saveContext()
    }

    func saveContext() {
        if mainManagedObjectContext.hasChanges {
            do {
                try mainManagedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it
                // may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func delete(_ object: NSManagedObject) {
        mainManagedObjectContext.delete(object)
    }

    // MARK: - Games

    func createGame(from gameStruct: GameStruct, completion: @escaping (Game?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let game = Game(context: self.mainManagedObjectContext)
                game.name = gameStruct.name
                game.uuid = gameStruct.uuid
                game.author = gameStruct.author ?? "Anonymous"
                game.website = gameStruct.website
                game.license = gameStruct.license
                game.about = gameStruct.about
                game.font = GameFont(jsonDescription: gameStruct.font) ?? .normal
                try self.mainManagedObjectContext.save()

                // Create Attributes
                var attributesDict: [UUID: Attribute] = [:]
                for attributeStruct in gameStruct.attributes {
                    let attribute = Attribute(context: self.mainManagedObjectContext)
                    attribute.uuid = attributeStruct.uuid
                    attribute.name = attributeStruct.name
                    attribute.game = game
                    attributesDict[attributeStruct.uuid] = attribute
                    try self.mainManagedObjectContext.save()
                }

                // Create Pages
                var pagesDict: [UUID: Page] = [:]
                for pageStruct in gameStruct.pages {
                    let page = Page(context: self.mainManagedObjectContext)
                    page.uuid = pageStruct.uuid
                    page.content = pageStruct.content
                    page.type = PageType(jsonDescription: pageStruct.type) ?? .none
                    page.game = game
                    pagesDict[pageStruct.uuid] = page
                    try self.mainManagedObjectContext.save()
                }

                // Create Decisions
                for pageStruct in gameStruct.pages {
                    if let decisionStructs = pageStruct.decisions, !decisionStructs.isEmpty {
                        for decisionStruct in decisionStructs {
                            let decision = Decision(context: self.mainManagedObjectContext)
                            decision.uuid = decisionStruct.uuid
                            decision.content = decisionStruct.content
                            decision.page = pagesDict[pageStruct.uuid]!
                            if let destinationUUID = decisionStruct.destinationUuid {
                                decision.destination = pagesDict[destinationUUID]!
                            }
                            try self.mainManagedObjectContext.save()

                            // Create Rules
                            if let ruleStructs = decisionStruct.rules, !ruleStructs.isEmpty {
                                for ruleStruct in ruleStructs {
                                    let rule = Rule(context: self.mainManagedObjectContext)
                                    rule.uuid = ruleStruct.uuid
                                    rule.value = ruleStruct.value
                                    rule.type = RuleType(jsonDescription: ruleStruct.type) ?? .isEqualTo
                                    if let attributeUUID = ruleStruct.attributeUuid {
                                        rule.attribute = attributesDict[attributeUUID]!
                                    }
                                    rule.decision = decision
                                    try self.mainManagedObjectContext.save()
                                }
                            }
                        }
                    }

                    // Create Consequences
                    if let consequenceStructs = pageStruct.consequences, !consequenceStructs.isEmpty {
                        for consequenceStruct in consequenceStructs {
                            let consequence = Consequence(context: self.mainManagedObjectContext)
                            consequence.uuid = consequenceStruct.uuid
                            consequence.amount = consequenceStruct.amount
                            consequence.type = ConsequenceType(jsonDescription: consequenceStruct.type) ?? .set
                            if let attributeUUID = consequenceStruct.attributeUuid {
                                consequence.attribute = attributesDict[attributeUUID]
                            }
                            consequence.page = pagesDict[pageStruct.uuid]!
                            try self.mainManagedObjectContext.save()
                        }
                    }
                }

                self.saveContext()
                NotificationCenter.default.post(name: .didAddNewBook, object: nil)
                completion(game)
            } catch {
                completion(nil)
            }
        }
    }

    func createGame(name: String, completion: @escaping (Game?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let managedGame = Game(context: self.mainManagedObjectContext)
                managedGame.name = name
                managedGame.uuid = UUID()
                try self.mainManagedObjectContext.save()
                self.saveContext()
                NotificationCenter.default.post(name: .didAddNewBook, object: nil)
                completion(managedGame)
            } catch {
                completion(nil)
            }
        }
    }

    func fetchGames(completion: @escaping ([Game]?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
                let managedGames = try self.mainManagedObjectContext.fetch(fetchRequest) as [Game]
                completion(managedGames)
            } catch {
                completion(nil)
            }
        }
    }

    func deleteGame(_ game: Game, completion: @escaping (Game?) -> Void) {
        mainManagedObjectContext.delete(game)
        saveContext()
        completion(nil)
    }

    // MARK: - Pages

    func fetchPage(by uuid: String, completion: @escaping (Page?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Page> = Page.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
                if let page = try? self.mainManagedObjectContext.fetch(fetchRequest).first {
                    completion(page)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func fetchFirstPage(for game: Game, completion: @escaping (Page?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Page> = Page.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "type == %@ && game == %@", NSNumber(value: PageType.first.rawValue), game)
                if let managedPage = try self.mainManagedObjectContext.fetch(fetchRequest).first {
                    completion(managedPage)
                } else {
                    self.createPage(
                        for: game,
                        content: "This first page has been automatically generated for you. Replace it with your own content!",
                        type: .first,
                        completion: { page in
                            completion(page)
                        }
                    )
                }
            } catch {
                completion(nil)
            }
        }
    }

    func fetchAllPages(for game: Game, completion: @escaping ([Page]?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Page> = Page.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "game == %@ AND (origins.@count > 0 OR type == 1)", game)
                let managedPages = try self.mainManagedObjectContext.fetch(fetchRequest) as [Page]
                completion(managedPages)
            } catch {
                completion(nil)
            }
        }
    }

    func createPage(for game: Game, content: String, type: PageType, completion: @escaping (Page?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let managedPage = Page(context: self.mainManagedObjectContext)
                let savedContent = content
                managedPage.content = savedContent
                managedPage.type = type
                managedPage.uuid = UUID()
                managedPage.game = game
                try self.mainManagedObjectContext.save()
                self.saveContext()
                completion(managedPage)
            } catch {
                completion(nil)
            }
        }
    }

    func deletePage(_ page: Page, completion: @escaping (Page?) -> Void) {
        mainManagedObjectContext.delete(page)
        saveContext()
        completion(nil)
    }

    func searchPages(for game: Game, terms: String, completion: @escaping ([Page]) -> Void) {
        fetchAllPages(for: game) { pages in
            guard let pages = pages else {
                completion([])
                return
            }

            var filteredPages = [Page]()

            for page in pages {
                if page.content.lowercased().contains(terms.lowercased()) {
                    filteredPages.append(page)
                }
            }

            completion(filteredPages)
        }
    }

    // MARK: - Decisions

    func createDecision(
        for page: Page,
        content: String,
        destination: Page,
        completion: @escaping (Decision?) -> Void
    ) {
        if page.type != .ending {
            mainManagedObjectContext.perform {
                do {
                    let managedDecision = Decision(context: self.mainManagedObjectContext)
                    managedDecision.content = content
                    managedDecision.uuid = UUID()
                    managedDecision.page = page
                    managedDecision.destination = destination
                    try self.mainManagedObjectContext.save()
                    self.saveContext()
                    completion(managedDecision)
                } catch {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }

    func deleteDecision(_ decision: Decision, completion: @escaping (Decision?) -> Void) {
        mainManagedObjectContext.delete(decision)
        saveContext()
        completion(nil)
    }

    // MARK: - Rules

    func createRule(for decision: Decision, attribute _: Attribute?, type: RuleType?, value: Float?, completion: @escaping (Rule?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let managedRule = Rule(context: self.mainManagedObjectContext)
                managedRule.uuid = UUID()
                managedRule.decision = decision
                managedRule.value = value ?? 0
                managedRule.type = type ?? .isEqualTo
                try self.mainManagedObjectContext.save()
                self.saveContext()
                completion(managedRule)
            } catch {
                completion(nil)
            }
        }
    }

    func deleteRule(_ rule: Rule, completion: @escaping (Rule?) -> Void) {
        mainManagedObjectContext.delete(rule)
        saveContext()
        completion(nil)
    }

    // MARK: - Consequences

    func createConsequence(
        for page: Page,
        attribute: Attribute?,
        type: ConsequenceType?,
        amount: Float,
        completion: @escaping (Consequence?) -> Void
    ) {
        if page.type != .ending {
            mainManagedObjectContext.perform {
                do {
                    let managedConsequence = Consequence(context: self.mainManagedObjectContext)
                    managedConsequence.uuid = UUID()
                    managedConsequence.page = page
                    managedConsequence.type = type ?? .add
                    managedConsequence.amount = amount
                    managedConsequence.attribute = attribute
                    try self.mainManagedObjectContext.save()
                    self.saveContext()
                    completion(managedConsequence)
                } catch {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }

    func deleteConsequence(_ consequence: Consequence, completion: @escaping (Consequence?) -> Void) {
        mainManagedObjectContext.delete(consequence)
        saveContext()
        completion(nil)
    }

    // MARK: - Attributes

    func createAttribute(for game: Game, name: String, completion: @escaping (Attribute?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let managedAttribute = Attribute(context: self.mainManagedObjectContext)
                managedAttribute.name = name
                managedAttribute.uuid = UUID()
                managedAttribute.game = game
                try self.mainManagedObjectContext.save()
                self.saveContext()
                completion(managedAttribute)
            } catch {
                completion(nil)
            }
        }
    }

    func fetchAllAttributes(for game: Game, completion: @escaping ([Attribute]?) -> Void) {
        do {
            let fetchRequest: NSFetchRequest<Attribute> = Attribute.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "game == %@", game)
            let managedAttributes = try mainManagedObjectContext.fetch(fetchRequest) as [Attribute]
            completion(managedAttributes)
        } catch {
            completion(nil)
        }
    }

    func deleteAttribute(_ attribute: Attribute, completion: @escaping (Attribute?) -> Void) {
        mainManagedObjectContext.delete(attribute)
        saveContext()
        completion(nil)
    }
}
