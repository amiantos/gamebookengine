//
//  GameListGameTableViewCell.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/29/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol GameListGameTableViewCellDelegate: AnyObject {
    func editGame(_ game: Game)
    func deleteGame(_ game: Game)
    func exportGame(_ game: Game)
}

class GameListGameTableViewCell: UITableViewCell {
    var game: Game? {
        didSet {
            setup()
        }
    }

    weak var delegate: GameListGameTableViewCellDelegate?

    @IBOutlet var separatorView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var aboutLabel: UILabel!
    @IBOutlet var byLineAboutConstraint: NSLayoutConstraint!
    @IBOutlet var gameContainerView: ContainerView!
    @IBOutlet var exportButton: UIButton!

    @IBAction func exportAction(_: UIButton) {
        guard let game = game else { return }
        delegate?.exportGame(game)
    }

    @IBAction func editAction(_: UIButton) {
        guard let game = game else { return }
        delegate?.editGame(game)
    }

    @IBAction func deleteAction(_: UIButton) {
        guard let game = game else { return }
        delegate?.deleteGame(game)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func setup() {
        guard let game = game else { return }
        titleLabel.text = game.name
        authorLabel.text = game.author
        aboutLabel.text = game.about
        if game.about?.isEmpty ?? true {
            byLineAboutConstraint.constant = 0
        } else {
            byLineAboutConstraint.constant = 16
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        let highlightAnimator = UIViewPropertyAnimator(duration: 0.05, curve: .linear) {
            [weak self] in
            self?.gameContainerView.layer.shadowOpacity = 0.1
        }

        let unhighlightAnimator = UIViewPropertyAnimator(duration: 0.05, curve: .linear) {
            [weak self] in
            self?.gameContainerView.layer.shadowOpacity = 0.0
        }

        // Animates the cell's shadow when the highlighted property changes
        if highlighted {
            unhighlightAnimator.startAnimation()
        } else {
            highlightAnimator.startAnimation()
        }
    }
}
