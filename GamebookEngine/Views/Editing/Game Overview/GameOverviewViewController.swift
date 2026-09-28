//
//  GameOverviewViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 9/3/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit
import UIKit

class GameOverviewViewController: UIViewController, PagesTableViewDelegate {
    var game: Game?
    var scene: PagesScene?
    var skView: SKView?
    weak var delegate: PagesTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = game?.name ?? "Gamebook Overview"

        view = SKView(frame: UIScreen.main.bounds)
        scene = PagesScene(size: view.bounds.size)
        scene!.game = game
        scene!.scaleMode = .aspectFill
        scene!.pageDelegate = self

        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.showsDrawCount = false
        skView?.showsNodeCount = false
        skView?.showsFPS = false
        skView!.presentScene(scene)

        configureBarItems()
    }

    private func configureBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Exit Editor", image: UIImage(systemName: "xmark"),
            primaryAction: UIAction { [weak self] _ in self?.exitGame() }
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit Metadata", image: UIImage(systemName: "info"),
            primaryAction: UIAction { [weak self] _ in self?.metaAction() }
        )

        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Overview", style: .plain, target: nil, action: nil
        )

        let searchButton = UIBarButtonItem(
            title: "Search Pages", image: UIImage(systemName: "magnifyingglass"),
            primaryAction: UIAction { [weak self] _ in self?.searchButtonTapped() }
        )
        toolbarItems = [.flexibleSpace(), searchButton]
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                Log.debug("Changed to light style.")
                scene?.changeToLightMode()
            } else if traitCollection.userInterfaceStyle == .dark {
                Log.debug("Changed to dark style.")
                scene?.changeToDarkMode()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scene?.redrawPages()
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    @objc func exitGame() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func metaAction() {
        let view = MetadataEditorViewController()
        view.game = game
        navigationController?.pushViewController(view, animated: true)
    }

    @objc func searchButtonTapped() {
        guard let game = game else { return }
        let pagesView = PagesTableViewController(for: game)
        pagesView.delegate = self
        navigationController?.pushViewController(pagesView, animated: true)
    }

    func selectedPage(_ page: Page) {
        let pageEditor = PageEditorViewController()
        pageEditor.currentGame = game
        navigationController?.pushViewController(pageEditor, animated: true)
        pageEditor.currentPage = page
        pageEditor.pageScene = scene
    }

    func deletedPage(_: Page) {}
}
