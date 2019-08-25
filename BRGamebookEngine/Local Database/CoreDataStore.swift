//
//  CoreDataStore.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import CoreData
import Foundation
import UIKit

enum StorageError: Error {
    case cannotFetch(String)
    case cannotCreate(String)
    case cannotUpdate(String)
    case cannotDelete(String)
}

struct StorageResult {
    let resultsTotal: Int
    let items: [Any]?
}

class CoreDataStore {
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

    // MARK: - Games

    func createGame(name: String, completion: @escaping (Game?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let managedGame = Game(context: self.mainManagedObjectContext)
                managedGame.name = name
                managedGame.uuid = UUID()
                try self.mainManagedObjectContext.save()
                self.saveContext()
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

    func fetchFirstPage(for game: Game, completion: @escaping (Page?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Page> = Page.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "type == %@ && game == %@", "first", game)
                if let managedPage = try self.mainManagedObjectContext.fetch(fetchRequest).first {
                    completion(managedPage)
                } else {
                    self.createPage(
                        for: game,
                        content: NSAttributedString(
                            string: "This first page has been automatically generated for you. Replace it with your own content!",
                            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
                        ),
                        type: "first",
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
                fetchRequest.predicate = NSPredicate(format: "game == %@", game)
                let managedPages = try self.mainManagedObjectContext.fetch(fetchRequest) as [Page]
                completion(managedPages)
            } catch {
                completion(nil)
            }
        }
    }

    func createPage(for game: Game, content: NSAttributedString, type: String?, completion: @escaping (Page?) -> Void) {
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

    // MARK: - Decisions

    func createDecision(
        for page: Page,
        content: NSAttributedString,
        destination: Page,
        completion: @escaping (Decision?) -> Void
    ) {
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
    }

    func deleteDecision(_ decision: Decision, completion: @escaping (Decision?) -> Void) {
        mainManagedObjectContext.delete(decision)
        saveContext()
        completion(nil)
    }

    // MARK: - Consequences

    func createConsequence(for page: Page, attribute _: Attribute?, type: ConsequenceType?, amount: Int32, completion: @escaping (Consequence?) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let managedConsequence = Consequence(context: self.mainManagedObjectContext)
                managedConsequence.uuid = UUID()
                managedConsequence.page = page
                managedConsequence.type = type ?? .add
                managedConsequence.amount = amount
                try self.mainManagedObjectContext.save()
                self.saveContext()
                completion(managedConsequence)
            } catch {
                completion(nil)
            }
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
