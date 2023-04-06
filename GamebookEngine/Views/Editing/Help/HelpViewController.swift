//
//  HelpViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Editor Help"
        guard let readMeURL = Bundle.main.url(forResource: "Help", withExtension: "md"),
              let readMeContents = try? String(contentsOf: readMeURL)
        else { return }

        textView.attributedText = BRMarkdownParser.standard.convertToAttributedString(readMeContents, with: .normal)
    }
}
