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

        let exitButton = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitGame))
        let metaButton = UIBarButtonItem(title: "Edit Metadata", style: .plain, target: self, action: #selector(metaAction))
        navigationItem.leftBarButtonItem = exitButton
        navigationItem.rightBarButtonItem = metaButton
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func exitGame() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func metaAction() {
        let view = MetadataEditorViewController()
        view.game = game
        navigationController?.pushViewController(view, animated: true)
    }

    func selectedPage(_ page: Page) {
        let pageEditor = PageEditorViewController()
        pageEditor.currentGame = game
        navigationController?.pushViewController(pageEditor, animated: true)
        pageEditor.currentPage = page
        pageEditor.pageScene = scene
    }

    func deletedPage(_: Page) {
        return
    }
}
