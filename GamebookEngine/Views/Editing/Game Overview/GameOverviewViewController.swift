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
    var searchButton: UIButton!
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

        searchButton = UIButton()
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.imageView?.tintColor = UIColor(named: "button")
        searchButton.backgroundColor = UIColor(named: "containerBackground")

        searchButton.layer.cornerRadius = 5
        searchButton.layer.masksToBounds = false
        searchButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        searchButton.layer.shadowOpacity = 0.3
        searchButton.layer.shadowRadius = 4
        searchButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        view.addSubview(searchButton)

        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
        ])
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
