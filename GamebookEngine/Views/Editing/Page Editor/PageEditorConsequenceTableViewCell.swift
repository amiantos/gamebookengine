//
//  PageEditorConsequenceTableViewCell.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol PageEditorConsequenceTableViewCellDelegate: AnyObject {
    func editConsequence(_ consequence: Consequence)
    func deleteConsequence(_ consequence: Consequence)
}

class PageEditorConsequenceTableViewCell: UITableViewCell {
    var consequence: Consequence? {
        didSet {
            setup()
        }
    }

    weak var delegate: PageEditorConsequenceTableViewCellDelegate?

    @IBOutlet var containerView: ContainerView!
    @IBOutlet var attributeNameLabel: UILabel!
    @IBOutlet var attributeWarningImage: UIImageView!
    @IBOutlet var attributeWarningLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!

    @IBAction func editButtonAction(_: UIButton) {
        guard let consequence = consequence else { return }
        delegate?.editConsequence(consequence)
    }

    @IBAction func deleteButtonAction(_: UIButton) {
        guard let consequence = consequence else { return }
        delegate?.deleteConsequence(consequence)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func setup() {
        guard let consequence = consequence else { return }
        attributeNameLabel.text = "None"
        attributeWarningImage.isHidden = false
        attributeWarningLabel.isHidden = false
        if let attributeName = consequence.attribute?.name {
            attributeNameLabel.text = attributeName
            attributeWarningImage.isHidden = true
            attributeWarningLabel.isHidden = true
        }
        valueLabel.text = String(describing: consequence.amount)
        typeLabel.text = consequence.type.description
    }
}
