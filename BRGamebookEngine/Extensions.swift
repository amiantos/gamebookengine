//
//  Extensions.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation

extension Array {
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
