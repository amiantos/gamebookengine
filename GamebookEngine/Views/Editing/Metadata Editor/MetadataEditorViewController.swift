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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc fileprivate func keyboardWillShow(_: Notification) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(doneAction))
    }

    @objc fileprivate func keyboardWillHide(_: Notification) {
        navigationItem.rightBarButtonItem = nil
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
        view.endEditing(true)
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
