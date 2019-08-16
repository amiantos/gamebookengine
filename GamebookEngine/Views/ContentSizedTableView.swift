//
//  ContentSizedTableView.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 9/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

final class ContentSizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
