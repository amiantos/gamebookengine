//
//  PlayPageViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class PlayPageViewController: UIViewController {
    var currentGame: Game?
    var currentPage: Page? {
        didSet {
            loadContent()
        }
    }

    var currentDecisions: [Decision]?

    @IBOutlet var textView: UITextView!
    @IBOutlet var decisionsTableView: UITableView!
    @IBOutlet var decisionsTableViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        decisionsTableView.delegate = self
        decisionsTableView.dataSource = self
        decisionsTableView.register(UINib(nibName: "PlayDecisionTableViewCell", bundle: nil), forCellReuseIdentifier: "decisionCell")

        // Add start over button
        let startOverButton = UIBarButtonItem(title: "Restart", style: .plain, target: self, action: #selector(startOver))
        navigationItem.rightBarButtonItem = startOverButton

        if let game = currentGame {
            title = game.name
            if currentPage == nil {
                coreDataStore.fetchFirstPage(for: game) { page in
                    self.currentPage = page
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        super.updateViewConstraints()
        decisionsTableViewHeightConstraint?.constant = decisionsTableView.contentSize.height
    }

    fileprivate func loadContent() {
        guard let page = currentPage else { return }
        DispatchQueue.main.async {
            self.textView.attributedText = page.content
            if let decisions = page.decisions?.allObjects as? [Decision] {
                self.currentDecisions = decisions
            }
            self.decisionsTableView.reloadData()
        }
    }

    @objc fileprivate func startOver() {
        if let game = currentGame {
            coreDataStore.fetchFirstPage(for: game) { page in
                self.currentPage = page
            }
        }
    }
}

extension PlayPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, titleForHeaderInSection _: Int) -> String? {
        return "Decisions"
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return currentDecisions?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "decisionCell", for: indexPath)

        cell.textLabel?.text = currentDecisions?[indexPath.row].content.string

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let decision = currentDecisions?.item(at: indexPath.row) else { return }
        currentPage = decision.destination
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        view.tintColor = .darkText
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .white
        let view = UIView()
        view.backgroundColor = .black
        header.backgroundView = view
    }
}
