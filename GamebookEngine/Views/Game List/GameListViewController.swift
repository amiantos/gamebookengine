//
//  GameListViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/29/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

final class GameListViewController: UIHostingController<GameListView> {
    private let model: GameListModel

    init() {
        let model = GameListModel()
        self.model = model
        super.init(rootView: GameListView(model: model, onAction: { _ in }))
        rootView = GameListView(model: model) { [weak self] action in
            self?.handle(action)
        }
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func addGameAction(_ sender: UIBarButtonItem) {
        showFilePicker(sender)
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Gamebooks"
        configureNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchGames), name: .didAddNewBook, object: nil)
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true

        let addItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addGameAction(_:))
        )
        addItem.accessibilityLabel = "Add Gamebook"
        navigationItem.rightBarButtonItem = addItem

        let helpItem = UIBarButtonItem(
            image: UIImage(systemName: "questionmark"),
            style: .plain,
            target: self,
            action: #selector(showHelp)
        )
        helpItem.accessibilityLabel = "Help"
        navigationItem.leftBarButtonItem = helpItem
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchGames()
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchGames()
        showIntroductionScreen()
    }

    private func handle(_ action: GameListAction) {
        switch action {
        case let .play(game):
            loadGame(game)
        case let .edit(game):
            editGame(game)
        case let .export(game, format, sourceRect):
            exportGame(game, as: format, from: sourceRect)
        case let .delete(game):
            deleteGame(game)
        case .addGame:
            guard let addItem = navigationItem.rightBarButtonItem else { return }
            showFilePicker(addItem)
        case .help:
            showHelp()
        }
    }
}

// MARK: - Activities

extension GameListViewController: UIDocumentPickerDelegate {
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            Log.info("Open URL: \(url)")
            let didStartAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccess { url.stopAccessingSecurityScopedResource() }
            }
            do {
                let jsonData = try Data(contentsOf: url)
                GameSerializer.standard.gameFromJSONData(jsonData)
            } catch {
                Log.error("Failed to read picked file at \(url): \(error)")
            }
        }
    }

    @objc fileprivate func importGame() {
        var documentPicker: UIDocumentPickerViewController!
        if #available(iOS 14, *) {
            let supportedTypes: [UTType] = [UTType("net.amiantos.BRGamebookEngine.gbook")!]
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        } else {
            let supportedTypes = ["net.amiantos.BRGamebookEngine.gbook"]
            documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        }
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
        guard let textField = actionSheet.textFields?.first else { return }

        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = textField.text, !text.isEmpty else { return }
            GameDatabase.standard.createGame(name: text, completion: { game in
                guard let game = game else { return }
                DispatchQueue.main.async {
                    self.fetchGames()
                    self.editGame(game)
                }
            })
        }
        okButton.isEnabled = false
        actionSheet.addAction(okButton)

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
            guard let text = textField.text else { return }
            okButton.isEnabled = !text.isEmpty
        }

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)
        present(actionSheet, animated: true)
        actionSheet.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    @objc fileprivate func createDefaultGames() {
        let alert = UIAlertController.createCancelableAlert(
            title: "Add example games?",
            message: "Are you sure you want to add the example games to your library? This may duplicate the games if you already have them.",
            primaryActionTitle: "Add games"
        ) { _ in
            UserDatabase.standard.createDefaultGames()
            DispatchQueue.main.async {
                self.fetchGames()
            }
        }
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    @objc fileprivate func fetchGames() {
        model.fetchGames()
    }

    @objc fileprivate func showHelp() {
        let swiftUIViewController = UIHostingController(rootView: HelpView())
        swiftUIViewController.modalPresentationStyle = .pageSheet
        present(swiftUIViewController, animated: true, completion: nil)
    }

    @objc fileprivate func showIntroductionScreen() {
        if UserDatabase.standard.shouldShowIntroductoryScreen() {
            let swiftUIViewController = UIHostingController(rootView: IntroductionView())
            swiftUIViewController.modalPresentationStyle = .pageSheet
            swiftUIViewController.isModalInPresentation = true
            present(swiftUIViewController, animated: true, completion: nil)
        }
    }

    fileprivate func showFilePicker(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Add game", message: nil, preferredStyle: .actionSheet)
        let importAction = UIAlertAction(title: "Import game from file", style: .default) { _ in
            self.importGame()
        }
        let createAction = UIAlertAction(title: "Create new game", style: .default) { _ in
            self.createGame()
        }
        let createDefaultGamesAction = UIAlertAction(title: "Add example games", style: .default) { _ in
            self.createDefaultGames()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(createAction)
        actionSheet.addAction(importAction)
        actionSheet.addAction(createDefaultGamesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.barButtonItem = sender
        present(actionSheet, animated: true, completion: nil)
        actionSheet.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    func loadGame(_ game: Game) {
        let playPageView = PlayViewController(for: game)
        playPageView.modalPresentationStyle = .fullScreen
        present(playPageView, animated: true, completion: nil)
    }

    func editGame(_ game: Game) {
        model.editingGame = game
    }

    func deleteGame(_ game: Game) {
        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this game?",
            primaryActionTitle: "Delete"
        ) { _ in
            self.model.deleteGame(game)
        }
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    func exportGame(_ game: Game, as format: GameExportFormat, from sourceRect: CGRect) {
        let itemProvider: UIActivityItemProvider
        switch format {
        case .gbook:
            itemProvider = GamebookProvider(game: game)
        case .html:
            itemProvider = HTMLGamebookProvider(game: game)
        }

        let activityViewController = UIActivityViewController(activityItems: [itemProvider], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.sourceRect = view.convert(sourceRect, from: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Item Provider

class GamebookProvider: UIActivityItemProvider, @unchecked Sendable {
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
        temporaryURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + "\(game.name).gbook")
        Log.debug("Create temporary URL for \(game.name)")

        self.game = game
        super.init(placeholderItem: temporaryURL as Any)
    }
}

class HTMLGamebookProvider: UIActivityItemProvider, @unchecked Sendable {
    var temporaryURL: NSURL?
    var game: Game

    override var item: Any {
        guard let htmlString = GameSerializer.standard.toHTMLFile(game: game) else {
            fatalError("Error: Unable to generate HTML file")
        }
        let textData = htmlString.data(using: .utf8)
        guard let textURL = textData?.dataToFile(fileName: "\(game.name).html") else {
            fatalError("Error: Unable to save the HTML file")
        }
        Log.debug("Load \(game.name) at \(textURL)")
        return textURL
    }

    init(game: Game) {
        // Creates a URL to show a non-existent HTML file prior to loading the real file
        temporaryURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + "\(game.name).html")
        Log.debug("Create temporary URL for \(game.name)")

        self.game = game
        super.init(placeholderItem: temporaryURL as Any)
    }
}
