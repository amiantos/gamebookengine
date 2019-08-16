//
//  DecisionEditorRuleTableViewCell.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/25/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol DecisionEditorRuleTableViewCellDelegate: AnyObject {
    func deleteRule(_ rule: Rule)
    func editRule(_ rule: Rule)
}

class DecisionEditorRuleTableViewCell: UITableViewCell {
    var rule: Rule? {
        didSet {
            setup()
        }
    }

    weak var delegate: DecisionEditorRuleTableViewCellDelegate?

    @IBOutlet var attributeLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var containerView: UIView!

    @IBAction func editButtonAction(_: UIButton) {
        guard let rule = rule else { return }
        delegate?.editRule(rule)
    }

    @IBAction func deleteButtonAction(_: UIButton) {
        guard let rule = rule else { return }
        delegate?.deleteRule(rule)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
    }

    fileprivate func setup() {
        guard let rule = rule else { return }
        attributeLabel.text = "\(rule.attribute?.name ?? "NULL")"
        typeLabel.text = rule.type.description
        valueLabel.text = "\(rule.value)"
    }
}
