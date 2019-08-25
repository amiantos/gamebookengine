//
//  ConsequenceEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class ConsequenceEditorViewController: UIViewController, AttributesTableViewDelegate {
    var currentConsequence: Consequence?

    @IBAction func changeTypeAction(_ sender: UISegmentedControl) {
        if let consequenceType = ConsequenceType(rawValue: Int32(sender.selectedSegmentIndex)) {
            currentConsequence?.type = consequenceType
            coreDataStore.saveContext()
            loadContent()
        }
    }

    @IBAction func changeAttributeButton(_: UIButton) {
        let attributesView = AttributesTableViewController()
        attributesView.currentGame = currentConsequence?.page?.game
        attributesView.delegate = self
        navigationController?.pushViewController(attributesView, animated: true)
    }

    @IBAction func editedAmountAction(_: UITextField) {
        doneAction()
    }

    @IBAction func didBeginEditing(_ sender: UITextField) {
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.endOfDocument)
    }

    @IBOutlet var currentAttributeLabel: UILabel!
    @IBOutlet var currentTypeSegmentedControl: UISegmentedControl!
    @IBOutlet var currentAmountTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Consequence"

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction)),
        ]
        currentAmountTextField.inputAccessoryView = toolbar

        loadContent()
    }

    @objc fileprivate func doneAction() {
        currentConsequence?.amount = Int32(currentAmountTextField.text!) ?? 0
        coreDataStore.saveContext()
        loadContent()
        currentAmountTextField.resignFirstResponder()
    }

    fileprivate func loadContent() {
        if let consequence = currentConsequence {
            currentAttributeLabel.text = consequence.attribute?.name ?? "NULL"
            currentTypeSegmentedControl.selectedSegmentIndex = Int(consequence.type.rawValue)
            currentAmountTextField.text = "\(consequence.amount)"
        }
    }

    func selectedAttribute(_ attribute: Attribute) {
        currentConsequence?.attribute = attribute
        coreDataStore.saveContext()
        loadContent()
    }
}
