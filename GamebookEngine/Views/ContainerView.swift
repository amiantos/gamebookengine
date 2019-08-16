//
//  ContainerView.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 9/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class ContainerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 10
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
