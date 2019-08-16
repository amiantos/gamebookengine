//
//  GamesTableViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class GamesTableViewController: UITableViewController {
    var games: [Game] = []

    @IBOutlet var gameAddButton: UIBarButtonItem!
    @IBAction func gameAddButtonAction(_: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Name", message: "Name your new game", preferredStyle: .alert)
        actionSheet.addTextField { textField in
            textField.placeholder = "Game name..."
        }

        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = actionSheet.textFields?.first?.text, !text.isEmpty else { return }
            coreDataStore.createGame(name: text, completion: { game in
                guard let game = game else { return }
                DispatchQueue.main.async {
                    self.games.append(game)
                    self.tableView.reloadData()
                }
            })
        }
        actionSheet.addAction(okButton)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)

        present(actionSheet, animated: true)
    }

    fileprivate func fetchGames() {
        coreDataStore.fetchGames { games in
            if let games = games {
                DispatchQueue.main.async {
                    self.games = games
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchGames()
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return games.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCellIdentifier", for: indexPath)
        cell.textLabel?.text = games[indexPath.row].name
        return cell
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let game = self.games.item(at: indexPath.row) else { return }
        let playPageView = PlayPageViewController()
        playPageView.currentGame = game
        navigationController?.pushViewController(playPageView, animated: true)
    }

    override func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Delete
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            if let game = self.games.item(at: indexPath.row) {
                // TODO: We should confirm deletion here before deleting.
                coreDataStore.deleteGame(game, completion: { game in
                    if game == nil {
                        self.games.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
        // Edit
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { _, indexPath in
            guard let game = self.games.item(at: indexPath.row) else { return }
            let editPageView = PageEditorViewController()
            editPageView.currentGame = game
            self.navigationController?.pushViewController(editPageView, animated: true)
        }
        editAction.backgroundColor = .black
        // Rename
        let renameAction = UITableViewRowAction(style: .normal, title: "Rename") { _, indexPath in
            guard let game = self.games.item(at: indexPath.row) else { return }
            let actionSheet = UIAlertController(title: "Rename", message: "Change the name of this game", preferredStyle: .alert)
            actionSheet.addTextField { textField in
                textField.placeholder = game.name
            }

            let okButton = UIAlertAction(title: "OK", style: .default) { _ in
                guard let text = actionSheet.textFields?.first?.text, !text.isEmpty,
                    let cell = self.tableView.cellForRow(at: indexPath) else { return }
                game.name = text
                cell.textLabel?.text = text
                coreDataStore.saveContext()
            }
            actionSheet.addAction(okButton)

            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(cancelButton)

            self.present(actionSheet, animated: true)
        }
        return [editAction, renameAction, deleteAction]
    }
}
