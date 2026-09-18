//
//  RuleEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/26/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class RuleEditorViewController: UIViewController, AttributesTableViewDelegate {
    var currentRule: Rule?

    @IBOutlet var changeAttributeButton: UIButton!
    @IBOutlet var attributeLabel: UILabel!
    @IBAction func changeAttributeAction(_: UIButton) {
        guard let game = currentRule?.decision.page.game else { return }
        let attributesView = AttributesTableViewController(for: game)
        attributesView.delegate = self
        navigationController?.pushViewController(attributesView, animated: true)
    }

    @IBOutlet var ruleTypeSegmentedControl: UISegmentedControl!
    @IBAction func ruleTypeChangedAction(_ sender: UISegmentedControl) {
        if let ruleType = RuleType(rawValue: Int32(sender.selectedSegmentIndex)) {
            currentRule?.type = ruleType
            saveContent()
            loadContent()
        }
    }

    @IBOutlet var textField: UITextField!
    @IBAction func ruleValueEditingEnded(_: UITextField) {
        doneAction()
    }

    @IBAction func didBeginEditing(_ sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Rule Editor"

        changeAttributeButton.layer.cornerRadius = 5

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc fileprivate func keyboardWillShow(_: Notification) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(doneAction))
    }

    @objc fileprivate func keyboardWillHide(_: Notification) {
        navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        saveContent()
        super.viewWillDisappear(animated)
    }

    @objc fileprivate func doneAction() {
        saveContent()
        loadContent()
        textField.resignFirstResponder()
    }

    fileprivate func loadContent() {
        if let rule = currentRule {
            attributeLabel.text = rule.attribute?.name ?? "NULL"
            ruleTypeSegmentedControl.selectedSegmentIndex = Int(rule.type.rawValue)
            textField.text = "\(rule.value)"
        }
    }

    func selectedAttribute(_ attribute: Attribute?) {
        currentRule?.attribute = attribute
        saveContent()
        loadContent()
    }

    func saveContent() {
        currentRule?.value = Float(textField.text!) ?? 0
        GameDatabase.standard.saveContext()
    }
}
