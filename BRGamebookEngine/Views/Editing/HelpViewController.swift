//
//  HelpViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Down
import UIKit

class HelpViewController: UIViewController {
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Editor Help"
        guard let readMeURL = Bundle.main.url(forResource: "Help", withExtension: "md"),
            let readMeContents = try? String(contentsOf: readMeURL)
            else { return }

        let helpText = Down(markdownString: readMeContents)
        do {
            // swiftlint:disable line_length
            textView.attributedText = try? helpText.toAttributedString(.default, stylesheet: "* {font-family: sans-serif;} p {font-size: 13pt;text-indent:0.7em;} code, pre { font-family: Menlo; font-size: 12pt; font-weight: bold; }")
        }
    }
}
