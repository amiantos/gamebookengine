//
//  MarkdownParser.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/27/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import MarkdownKit

class BRMarkdownParser {
    static var standard: BRMarkdownParser = BRMarkdownParser()

    func convertToAttributedString(_ markdownString: String, with font: GameFont) -> NSAttributedString {
        // Color
        let textColor: UIColor = UIColor(named: "text") ?? .black
        // Font
        var fontStyle: UIFont = UIFont.preferredFont(forTextStyle: .body)
        switch font {
        case .serif:
            guard let serifFont = UIFont(name: "Georgia", size: 18) else { break }
            fontStyle = UIFontMetrics(forTextStyle: .body).scaledFont(for: serifFont)
        default:
            break
        }
        let markdownParser = MarkdownParser(font: fontStyle, color: textColor)
        markdownParser.link.color = textColor
        markdownParser.link.font = fontStyle
        return markdownParser.parse(markdownString)
    }

    func convertToAttributedString(_ markdownString: String, with font: UIFont) -> NSAttributedString {
        // Color
        let textColor: UIColor = UIColor(named: "text") ?? .black
        let markdownParser = MarkdownParser(font: font, color: textColor)
        markdownParser.link.color = textColor
        markdownParser.link.font = font
        return markdownParser.parse(markdownString)
    }
}
