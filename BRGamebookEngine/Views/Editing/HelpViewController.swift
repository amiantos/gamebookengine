//
//  HelpViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Down
import UIKit

let helpMarkdown = """
This editor helps you create simple interactive books, where readers can make decisions that influence the story.

There are several core building blocks that should be understood: **Attributes**, **Pages**, **Decisions**, and **Consequences**.
"""

class HelpViewController: UIViewController {
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Editor Help"

        let helpText = Down(markdownString: helpMarkdown)
        do {
            textView.attributedText = try? helpText.toAttributedString(.default, stylesheet: "* {font-family: sans-serif; font-size: 14pt; } code, pre { font-family: Menlo }")
        }
    }
}
