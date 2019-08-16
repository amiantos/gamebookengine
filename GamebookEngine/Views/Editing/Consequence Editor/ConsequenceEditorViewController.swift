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
            GameDatabase.standard.saveContext()
            loadContent()
        }
    }

    @IBAction func changeAttributeButton(_: UIButton) {
        guard let game = currentConsequence?.page?.game else { return }
        let attributesView = AttributesTableViewController(for: game)
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
    @IBOutlet var changeAttributeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Consequence Editor"

        changeAttributeButton.layer.cornerRadius = 5

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction)),
        ]
        currentAmountTextField.inputAccessoryView = toolbar
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
        currentAmountTextField.resignFirstResponder()
    }

    fileprivate func loadContent() {
        if let consequence = currentConsequence {
            currentAttributeLabel.text = consequence.attribute?.name ?? "NULL"
            currentTypeSegmentedControl.selectedSegmentIndex = Int(consequence.type.rawValue)
            currentAmountTextField.text = "\(consequence.amount)"
        }
    }

    func selectedAttribute(_ attribute: Attribute?) {
        currentConsequence?.attribute = attribute
        GameDatabase.standard.saveContext()
        loadContent()
    }

    func saveContent() {
        currentConsequence?.amount = Float(currentAmountTextField.text!) ?? 0
        GameDatabase.standard.saveContext()
    }
}
