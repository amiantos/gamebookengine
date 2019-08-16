//
//  PageTableViewCell.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell {
    @IBOutlet var excerptLabel: UILabel!
    @IBOutlet var decisionValueLabel: UILabel!
    @IBOutlet var consequenceValueLabel: UILabel!
    @IBOutlet var pageTypeLabel: UILabel!

    var page: Page? {
        didSet {
            if let page = page {
                excerptLabel.text = page.content.replacingOccurrences(of: "\n\n", with: " ")
                decisionValueLabel.text = String(describing: page.decisions?.count ?? 0)
                consequenceValueLabel.text = String(describing: page.consequences?.count ?? 0)
                switch page.type {
                case .first:
                    pageTypeLabel.text = "First Page"
                case .ending:
                    pageTypeLabel.text = "Ending Page"
                default:
                    pageTypeLabel.text = "Normal Page"
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
