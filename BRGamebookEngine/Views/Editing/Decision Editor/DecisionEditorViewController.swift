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
    var currentRules: [Rule] = []

    @IBOutlet var textView: UITextView!
    @IBAction func changeDestination(_: UIButton) {
        let pagesView = PagesTableViewController()
        pagesView.currentGame = currentDecision?.page.game
        pagesView.delegate = self
        navigationController?.pushViewController(pagesView, animated: true)
    }

    @IBOutlet var destinationPreviewLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        guard let decision = currentDecision, let matchType = MatchType(rawValue: Int32(sender.selectedSegmentIndex)) else { return }
        decision.matchStyle = matchType
        saveContent()
    }
    @IBAction func addRuleButtonAction(_ sender: UIButton) {
        addRule()
    }

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

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DecisionEditorRuleTableViewCell", bundle: nil), forCellReuseIdentifier: "ruleCell")

        loadContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContent()
    }

    @objc func doneAction() {
        textView.resignFirstResponder()
        saveContent()
    }

    fileprivate func addRule() {
        coreDataStore.createRule(for: currentDecision!, attribute: nil, type: nil, value: nil) { (rule) in
            if rule != nil {
                DispatchQueue.main.async {
                    self.loadContent()
                }
            }
        }

    }

    fileprivate func loadContent() {
        if let decision = currentDecision {
            textView.attributedText = decision.content
            destinationPreviewLabel.text = decision.destination?.content?.string ?? "No destination set!"
            segmentedControl.selectedSegmentIndex = Int(decision.matchStyle.rawValue)
            currentRules = currentDecision?.rules?.allObjects as? [Rule] ?? []
            tableView.reloadData()
        }
    }

    fileprivate func saveContent() {
        guard let decision = currentDecision else { return }
        decision.content = textView.attributedText
        coreDataStore.saveContext()
    }
}

extension DecisionEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ruleCell", for: indexPath)

        guard let rule = currentRules.item(at: indexPath.row) else { fatalError() }
        cell.textLabel?.text = "\(rule.attribute?.name ?? "NULL") \(rule.type.description) \(rule.value)"

        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _, indexPath in
            guard let rule = self.currentRules.item(at: indexPath.row) else { return }
            let ruleEditor = RuleEditorViewController()
            ruleEditor.currentRule = rule
            self.navigationController?.pushViewController(ruleEditor, animated: true)
        }
        editAction.backgroundColor = .black

//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
//            guard let consequence = self.currentConsequences?.item(at: indexPath.row) else { return }
//            coreDataStore.deleteConsequence(consequence, completion: { consequence in
//                if consequence == nil {
//                    DispatchQueue.main.async {
//                        self.currentConsequences?.remove(at: indexPath.row)
//                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                    }
//                }
//            })
//        }
        return [editAction]


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
