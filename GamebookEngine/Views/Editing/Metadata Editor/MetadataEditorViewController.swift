//
//  MetadataEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class MetadataEditorViewController: UIViewController {
    var game: Game?

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var authorTextField: UITextField!
    @IBOutlet var websiteTextField: UITextField!
    @IBOutlet var licenseTextField: UITextField!
    @IBOutlet var aboutTextView: UITextView!
    @IBOutlet var fontSegmentedControl: UISegmentedControl!
    @IBOutlet var containerView: ContainerView!

    @IBAction func dismissKeyboard(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Metadata Editor"

        aboutTextView.layer.cornerRadius = 5
        aboutTextView.layer.borderWidth = 0.5
        if #available(iOS 13.0, *) {
            aboutTextView.layer.borderColor = UIColor.separator.cgColor
        } else {
            aboutTextView.layer.borderColor = UIColor.lightGray.cgColor
        }

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction)),
        ]
        aboutTextView.inputAccessoryView = toolbar
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        loadContent()
    }

    override func viewWillDisappear(_: Bool) {
        saveContent()
        super.viewWillDisappear(true)
    }

    @objc fileprivate func doneAction() {
        saveContent()
        loadContent()
        aboutTextView.resignFirstResponder()
    }

    func loadContent() {
        guard let game = game else { return }
        titleTextField.text = game.name
        authorTextField.text = game.author
        websiteTextField.text = game.website?.absoluteString ?? ""
        licenseTextField.text = game.license
        aboutTextView.text = game.about ?? ""
        fontSegmentedControl.selectedSegmentIndex = Int(game.font.rawValue)
    }

    func saveContent() {
        guard let game = game else { return }
        Log.info("Saving game metadata...")
        game.name = titleTextField.text ?? "Default Name"
        game.author = authorTextField.text ?? "Anonymous"
        game.license = licenseTextField.text
        game.website = URL(string: websiteTextField.text ?? "")
        game.about = aboutTextView.text
        game.font = GameFont(rawValue: Int32(fontSegmentedControl.selectedSegmentIndex)) ?? .normal
        GameDatabase.standard.saveContext()
    }
}
