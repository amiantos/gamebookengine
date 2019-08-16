//
//  AttributeTableViewCell.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/23/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol AttributeTableViewCellDelegate: AnyObject {
    func deleteAttribute(_ attribute: Attribute)
}

class AttributeTableViewCell: UITableViewCell {
    weak var delegate: AttributeTableViewCellDelegate?

    @IBOutlet var attributeLabel: UILabel!
    @IBAction func deleteAction(_: UIButton) {
        guard let attribute = attribute else { return }
        delegate?.deleteAttribute(attribute)
    }

    var attribute: Attribute? {
        didSet {
            setup()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func setup() {
        guard let attribute = attribute else { return }
        attributeLabel.text = attribute.name
    }
}
