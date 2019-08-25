//
//  DecisionEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class DecisionEditorViewController: UIViewController {
    var currentDecision: Decision?

    @IBOutlet var textView: UITextView!
    @IBAction func changeDestination(_: UIButton) {
        let pagesView = PagesTableViewController()
        pagesView.currentGame = currentDecision?.page.game
        pagesView.delegate = self
        navigationController?.pushViewController(pagesView, animated: true)
    }

    @IBOutlet var destinationPreviewLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlChanged(_: UISegmentedControl) {}

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Decision"

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction)),
        ]
        textView.inputAccessoryView = toolbar

        textView.allowsEditingTextAttributes = true

        loadContent()
    }

    @objc func doneAction() {
        textView.resignFirstResponder()
        saveContent()
    }

    fileprivate func loadContent() {
        if let decision = currentDecision {
            textView.attributedText = decision.content
            destinationPreviewLabel.text = decision.destination?.content?.string ?? "No destination set!"
        }
    }

    fileprivate func saveContent() {
        guard let decision = currentDecision else { return }
        decision.content = textView.attributedText
        coreDataStore.saveContext()
    }
}

extension DecisionEditorViewController: PagesTableViewDelegate {
    func selectedPage(_ page: Page) {
        guard let decision = currentDecision else { return }
        decision.destination = page
        coreDataStore.saveContext()
        loadContent()
    }

    func deletedPage(_: Page) {
        loadContent()
    }
}

extension DecisionEditorViewController: UITextViewDelegate {
    func textViewDidEndEditing(_: UITextView) {
        saveContent()
    }
}
