//
//  PlayViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    private var player: GamePlayer

    private var decisionsAreHidden: Bool = false
    private var optionsContainerTopConstraint: NSLayoutConstraint?

    @IBOutlet var textView: UITextView!
    @IBOutlet var decisionsTableView: UITableView!
    @IBOutlet var decisionsContainerView: ContainerView!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var decisionsLabel: UILabel!
    @IBOutlet var optionsContainerView: UIView!

    @IBAction func exitButtonAction(_: UIButton) {
        exitGame()
    }

    @IBAction func restartButtonAction(_: UIButton) {
        restartGame()
    }

    // MARK: Initialization

    init(for game: Game) {
        player = GamePlayer(for: game)
        super.init(nibName: nil, bundle: nil)
        player.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup table view
        decisionsTableView.delegate = self
        decisionsTableView.dataSource = self
        decisionsTableView.register(UINib(nibName: "PlayDecisionTableViewCell", bundle: nil), forCellReuseIdentifier: "decisionCell")

        // Setup link colors in textview
        var linkColor: UIColor = .darkGray
        var underlineColor: UIColor = .lightGray
        if #available(iOS 13.0, *) {
            linkColor = .secondaryLabel
            underlineColor = .quaternaryLabel
        }
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: linkColor,
            NSAttributedString.Key.underlineColor: underlineColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        textView.linkTextAttributes = linkAttributes
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidePage()
        loadGame()
    }
}

// MARK: - Activities

extension PlayViewController: GamePlayerDelegate {
    fileprivate func loadGame() {
        player.loadGame()
    }

    func loadPage() {
        UIView.animate(withDuration: 0.3, animations: {
            self.hidePage()
        }, completion: { _ in
            self.showPage()
        })
    }

    @objc fileprivate func restartGame() {
        let alert = UIAlertController.createCancelableAlert(
            title: "Restart Game?",
            message: "Are you sure you want to restart this game? All progress will be reset and you'll begin at the first page.",
            primaryActionTitle: "Restart"
        ) { _ in
            self.player.restartGame()
        }
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    @objc fileprivate func exitGame() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UI Actions

extension PlayViewController {
    fileprivate func hidePage() {
        var textAreaFrame = textView.frame
        textAreaFrame.origin.x -= textAreaFrame.size.width / 2
        textView.frame = textAreaFrame
        textView.alpha = 0
        decisionsLabel.alpha = 0
        decisionsContainerView.alpha = 0
        optionsContainerView.alpha = 0
    }

    fileprivate func showPage() {
        textView.attributedText = player.getPageAttributedString()
        decisionsTableView.reloadData()

        if player.decisions.isEmpty {
            hideDecisionsView()
        } else {
            showDecisionsView()
        }

        mainScrollView.setContentOffset(.zero, animated: false)

        var containerFrame = textView.frame
        containerFrame.origin.x += containerFrame.size.width / 2
        textView.frame = containerFrame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.3, animations: {
                if !self.decisionsAreHidden {
                    self.decisionsLabel.alpha = 1
                    self.decisionsContainerView.alpha = 1
                }
                self.textView.alpha = 1
                self.optionsContainerView.alpha = 1
            })
        }
    }

    fileprivate func hideDecisionsView() {
        decisionsAreHidden = true
        optionsContainerTopConstraint?.isActive = false
        optionsContainerTopConstraint = optionsContainerView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 32)
        optionsContainerTopConstraint?.isActive = true
    }

    fileprivate func showDecisionsView() {
        optionsContainerTopConstraint?.isActive = false
        decisionsAreHidden = false
        optionsContainerTopConstraint = optionsContainerView.topAnchor.constraint(
            equalTo: decisionsContainerView.bottomAnchor,
            constant: 32
        )
        optionsContainerTopConstraint?.isActive = true
    }
}

// MARK: Decisions Table View Delegate

extension PlayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return player.decisions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "decisionCell",
            for: indexPath
        ) as? PlayDecisionTableViewCell else { fatalError() }

        cell.decisionTextLabel?.text = player.decisions[indexPath.row].content
        switch player.getFont() {
        case .serif:
            cell.decisionTextLabel?.font = UIFont(name: "Georgia", size: cell.decisionTextLabel?.font.pointSize ?? 16)
        default:
            cell.decisionTextLabel?.font = cell.decisionTextLabel?.font
        }

        cell.separatorView.isHidden = false
        if indexPath.row == player.decisions.count - 1 {
            cell.separatorView.isHidden = true
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        player.pickedDecision(at: indexPath.row)
    }
}
