//
//  GameListTableViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/29/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class GameListTableViewController: UITableViewController {
    var games: [Game] = []

    @IBOutlet var topBarView: UIView!
    @IBOutlet var bottomBarView: UIView!

    @IBOutlet var patronButton: UIButton!
    @IBAction func patronButtonAction(_: UIButton) {
        Log.debug("Tapped on website button.")
        UIApplication.shared.open(
            URL(
                string: "https://amiantos.net?utm_source=gamebook_ios&utm_medium=button&utm_campaign=game_list"
            )!,
            options: [:],
            completionHandler: nil
        )
    }

    @IBAction func topBarAddAction(_ sender: UIButton) {
        showFilePicker(sender)
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Your Gamebooks"
        tableView.register(UINib(nibName: "GameListGameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameCell")
        NotificationCenter.default.addObserver(self, selector: #selector(fetchGames), name: .didAddNewBook, object: nil)
        tableView.tableHeaderView = topBarView
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchGames()
        super.viewWillAppear(animated)

        patronButton.layer.cornerRadius = 10
        patronButton.layer.shadowRadius = 10
        patronButton.layer.shadowOffset = .zero
        patronButton.layer.shadowOpacity = 0.1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchGames()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = bottomBarView
        }
    }

    // MARK: - Table View

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return games.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "gameCell",
            for: indexPath
        ) as? GameListGameTableViewCell,
            let game = games.item(at: indexPath.row) else { fatalError() }
        cell.game = game
        cell.delegate = self

        cell.separatorView.isHidden = false
        if indexPath.row == games.count - 1 {
            cell.separatorView.isHidden = true
        }

        return cell
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let game = self.games.item(at: indexPath.row) else { return }
        loadGame(game)
    }
}

// MARK: - Activities

extension GameListTableViewController: GameListGameTableViewCellDelegate, UIDocumentPickerDelegate {
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            Log.info("Open URL: \(url)")
            guard let jsonData = try? Data(contentsOf: url) else { continue }
            GameSerializer.standard.gameFromJSONData(jsonData)
        }
    }

    fileprivate func loadGame(_ game: Game) {
        let playPageView = PlayViewController(for: game)
        playPageView.modalPresentationStyle = .fullScreen
        present(playPageView, animated: true, completion: nil)
    }

    @objc fileprivate func importGame() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["net.amiantos.BRGamebookEngine.gbook"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }

    @objc fileprivate func createGame() {
        let actionSheet = UIAlertController(title: "New Game", message: "Name your new game!", preferredStyle: .alert)
        actionSheet.addTextField { textField in
            textField.autocapitalizationType = .words
            textField.placeholder = "A Magnificent Voyage"
        }

        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = actionSheet.textFields?.first?.text, !text.isEmpty else { return }
            GameDatabase.standard.createGame(name: text, completion: { game in
                guard let game = game else { return }
                DispatchQueue.main.async {
                    self.fetchGames()
                    self.editGame(game)
                }
            })
        }
        actionSheet.addAction(okButton)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)
        present(actionSheet, animated: true)
        actionSheet.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    @objc fileprivate func fetchGames() {
        GameDatabase.standard.fetchGames { games in
            if let games = games {
                DispatchQueue.main.async {
                    self.games = games
                    self.tableView.reloadData()
                }
            }
        }
    }

    fileprivate func showFilePicker(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Add Game", message: nil, preferredStyle: .actionSheet)
        let importAction = UIAlertAction(title: "Import from file", style: .default) { _ in
            self.importGame()
        }
        let createAction = UIAlertAction(title: "Create New", style: .default) { _ in
            self.createGame()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(importAction)
        actionSheet.addAction(createAction)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = sender
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: sender.frame.width / 2 - 3, y: sender.frame.height, width: 0, height: 0)
        present(actionSheet, animated: true, completion: nil)
        actionSheet.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    func editGame(_ game: Game) {
        var textColor: UIColor = .black
        if #available(iOS 13.0, *) {
            textColor = .secondaryLabel
        }

        let gameOverview = GameOverviewViewController()
        gameOverview.game = game
        let navController = UINavigationController(rootViewController: gameOverview)
        navController.navigationBar.tintColor = textColor
        navController.modalPresentationStyle = .pageSheet
        if #available(iOS 13.0, *) {
            navController.isModalInPresentation = true
        }
        present(navController, animated: true, completion: nil)
    }

    func deleteGame(_ game: Game) {
        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this game?",
            primaryActionTitle: "Delete"
        ) { _ in
            let indexPath = IndexPath(row: self.games.firstIndex(of: game)!, section: 0)
            GameDatabase.standard.deleteGame(game, completion: { game in
                if game == nil {
                    self.games.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            })
        }
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    func exportGame(_ game: Game) {
        let gamebookDocument = GamebookProvider(game: game)
        let indexPathForGame = IndexPath(row: games.firstIndex(of: game)!, section: 0)
        guard let cell = tableView.cellForRow(at: indexPathForGame) as? GameListGameTableViewCell else { fatalError() }

        let activityViewController = UIActivityViewController(activityItems: [gamebookDocument], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = cell.exportButton
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 15, y: cell.exportButton.frame.height / 2, width: 0, height: 0)
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Item Provider

class GamebookProvider: UIActivityItemProvider {
    var temporaryURL: NSURL?
    var game: Game

    override var item: Any {
        let jsonString = GameSerializer.standard.toJSONString(game: game)
        let textData = jsonString.data(using: .utf8)
        guard let textURL = textData?.dataToFile(fileName: "\(game.name).gbook") else {
            fatalError("Error: Unable to load the gamebook")
        }
        Log.debug("Load \(game.name) at \(textURL)")
        return textURL
    }

    init(game: Game) {
        // Creates a URL to show a non-existent gamebook prior to loading the real gamebook
        self.temporaryURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + "\(game.name).gbook")
        Log.debug("Create temporary URL for \(game.name)")

        self.game = game
        super.init(placeholderItem: temporaryURL as Any)
    }
}
