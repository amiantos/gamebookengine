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

    @IBOutlet var playGamebookButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        playGamebookButton.layer.cornerRadius = 5
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
        // TODO: Replace this animation with proper UIViewPropertyAnimator setup
        switch highlighted {
        case true:
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = layer.shadowOpacity
            animation.toValue = 0.0
            animation.duration = 1
            gameContainerView.layer.add(animation, forKey: animation.keyPath)
            gameContainerView.layer.shadowOpacity = 0.0
        case false:
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = layer.shadowOpacity
            animation.toValue = 0.1
            animation.duration = 0.2
            gameContainerView.layer.add(animation, forKey: animation.keyPath)
            gameContainerView.layer.shadowOpacity = 0.1
        }
    }
}
