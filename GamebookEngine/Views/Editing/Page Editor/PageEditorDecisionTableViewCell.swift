//
//  PageEditorDecisionTableViewCell.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/22/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol PageEditorDecisionTableViewCellDelegate: AnyObject {
    func editDecision(_ decision: Decision)
    func deleteDecision(_ decision: Decision)
}

class PageEditorDecisionTableViewCell: UITableViewCell {
    var decision: Decision? {
        didSet {
            setup()
        }
    }

    weak var delegate: PageEditorDecisionTableViewCellDelegate?

    @IBOutlet var decisionContentLabel: UILabel!
    @IBOutlet var ruleLabel: UILabel!
    @IBOutlet var ruleValueLabel: UILabel!
    @IBOutlet var destinationValueLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var containerView: ContainerView!
    @IBOutlet var destinationWarningImage: UIImageView!
    @IBOutlet var destinationWarningLabel: UILabel!
    @IBOutlet var ruleWarningImage: UIImageView!
    @IBOutlet var ruleWarningLabel: UILabel!

    @IBAction func editAction(_: UIButton) {
        guard let decision = decision else { return }
        delegate?.editDecision(decision)
    }

    @IBAction func deleteAction(_: UIButton) {
        guard let decision = decision else { return }
        delegate?.deleteDecision(decision)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup() {
        guard let decision = decision else { return }
        decisionContentLabel.text = decision.content

        // MARK: Rule Display

        var ruleText = "No rules have been set."
        var ruleLabelText = "No Rules"
        ruleWarningImage.isHidden = true
        ruleWarningLabel.isHidden = true
        if let rules = decision.rules?.allObjects as? [Rule], !rules.isEmpty {
            ruleLabelText = "\(rules.count) Rules"
            if rules.count == 1 {
                ruleLabelText = "\(rules.count) Rule"
            }
            switch decision.matchStyle {
            case .matchAll:
                ruleText = "Match Style: All\n"
            case .matchAny:
                ruleText = "Match Style: Any\n"
            }
            var showWarning = false
            for rule in rules {
                if rule.attribute == nil {
                    showWarning = true
                }
                ruleText += " • \"\(rule.attribute?.name ?? "NULL")\" \(rule.type.description) \(rule.value)\n"
            }
            if showWarning {
                ruleWarningImage.isHidden = false
                ruleWarningLabel.isHidden = false
            } else {
                ruleWarningImage.isHidden = true
                ruleWarningLabel.isHidden = true
            }
        }
        ruleLabel.text = ruleLabelText
        ruleValueLabel.text = ruleText.trimmingCharacters(in: .newlines)

        // MARK: Destination Display

        var destinationText = "Destination has not been set."
        var destinationLabelText = "No Destination"
        destinationWarningImage.isHidden = false
        destinationWarningLabel.isHidden = false
        if let destination = decision.destination, !destination.content.isEmpty {
            destinationText = destination.content.replacingOccurrences(of: "\n\n", with: " ")
            destinationLabelText = "Destination"
            destinationWarningImage.isHidden = true
            destinationWarningLabel.isHidden = true
        }
        destinationValueLabel.text = destinationText
        destinationLabel.text = destinationLabelText
    }
}
