//
//  Extensions.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    /// Sets the text color for a navigation bar title.
    /// - Parameter color: Color the title should be
    ///
    /// Supports both regular and large titles.
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)

        // Set appearance for both normal and large sizes.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]

        return self
    }
}

func angleBetween(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
    let xdiff = (pointTwo.x - pointOne.x)
    let ydiff = (pointTwo.y - pointOne.y)
    let rad = atan2(ydiff, xdiff)
    return rad - (CGFloat.pi / 2)
}

extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (count > length) ? prefix(length) + trailing : self
    }
}

extension Notification.Name {
    static let didAddNewBook = Notification.Name("didAddNewBook")
}

extension Array {
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}

extension Data {
    func dataToFile(fileName: String) -> NSURL? {
        let data = self
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            return NSURL(fileURLWithPath: filePath)
        } catch {
            Log.error("Error writing the file: \(error.localizedDescription)")
        }
        return nil
    }
}
