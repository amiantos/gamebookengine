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

    @IBOutlet weak var attributeLabel: UILabel!
    @IBAction func changeAttributeAction(_ sender: UIButton) {
        let attributesView = AttributesTableViewController()
        attributesView.currentGame = currentRule?.decision.page.game
        attributesView.delegate = self
        navigationController?.pushViewController(attributesView, animated: true)
    }

    @IBOutlet weak var ruleTypeSegmentedControl: UISegmentedControl!
    @IBAction func ruleTypeChangedAction(_ sender: UISegmentedControl) {
        if let ruleType = RuleType(rawValue: Int32(sender.selectedSegmentIndex)) {
            currentRule?.type = ruleType
            coreDataStore.saveContext()
            loadContent()
        }
    }

    @IBOutlet weak var textField: UITextField!
    @IBAction func ruleValueEditingEnded(_ sender: UITextField) {
        doneAction()

    }

    @IBAction func didBeginEditing(_ sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Rule"

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction)),
        ]
        textField.inputAccessoryView = toolbar

        loadContent()

    }

    @objc fileprivate func doneAction() {
        currentRule?.value = Int32(textField.text!) ?? 0
        coreDataStore.saveContext()
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

    func selectedAttribute(_ attribute: Attribute) {
        currentRule?.attribute = attribute
        coreDataStore.saveContext()
        loadContent()
    }

}
