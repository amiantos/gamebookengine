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

    @IBOutlet var noRulesLabel: UILabel!
    @IBOutlet var containerView: ContainerView!
    @IBOutlet var textView: UITextView!
    @IBAction func changeDestination(_: UIButton) {
        guard let game = currentDecision?.page.game else { return }
        let pagesView = PagesTableViewController(for: game)
        pagesView.delegate = self
        navigationController?.pushViewController(pagesView, animated: true)
    }

    @IBOutlet var changeDestinationButton: UIButton!
    @IBOutlet var destinationPreviewLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        guard let decision = currentDecision, let matchType = MatchType(rawValue: Int32(sender.selectedSegmentIndex)) else { return }
        decision.matchStyle = matchType
        saveContent()
    }

    @IBAction func addRuleButtonAction(_: UIButton) {
        addRule()
    }

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Decision Editor"

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

        changeDestinationButton.layer.cornerRadius = 5
        textView.layer.cornerRadius = 5

        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 0.5
        if #available(iOS 13.0, *) {
            textView.layer.borderColor = UIColor.separator.cgColor
        } else {
            textView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        saveContent()
        super.viewWillDisappear(animated)
    }

    @objc func doneAction() {
        textView.resignFirstResponder()
        saveContent()
    }

    fileprivate func addRule() {
        GameDatabase.standard.createRule(for: currentDecision!, attribute: nil, type: nil, value: nil) { rule in
            guard let rule = rule else { return }
            DispatchQueue.main.async {
                self.currentRules.insert(rule, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.editRule(rule)
                self.noRulesLabel.isHidden = true
            }
        }
    }

    fileprivate func loadContent() {
        if let decision = currentDecision {
            textView.text = decision.content
            destinationPreviewLabel.text = decision.destination?.content.replacingOccurrences(of: "\n\n", with: " ") ?? "No destination set!"
            segmentedControl.selectedSegmentIndex = Int(decision.matchStyle.rawValue)
            currentRules = currentDecision?.rules?.allObjects as? [Rule] ?? []
            if currentRules.isEmpty {
                noRulesLabel.isHidden = false
            } else {
                noRulesLabel.isHidden = true
            }
            tableView.reloadData()
        }
    }

    fileprivate func saveContent() {
        guard let decision = currentDecision else { return }
        decision.content = textView.text
        GameDatabase.standard.saveContext()
    }
}

extension DecisionEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return currentRules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ruleCell",
            for: indexPath
        ) as? DecisionEditorRuleTableViewCell,
            let rule = currentRules.item(at: indexPath.row) else { fatalError() }

        cell.rule = rule
        cell.delegate = self

        return cell
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}

extension DecisionEditorViewController: PagesTableViewDelegate {
    func selectedPage(_ page: Page) {
        guard let decision = currentDecision else { return }
        decision.destination = page
        GameDatabase.standard.saveContext()
        loadContent()
        navigationController?.popViewController(animated: true)
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

extension DecisionEditorViewController: DecisionEditorRuleTableViewCellDelegate {
    func deleteRule(_ rule: Rule) {
        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this rule?",
            primaryActionTitle: "Delete"
        ) { _ in
            let indexPath = IndexPath(row: self.currentRules.firstIndex(of: rule)!, section: 0)
            GameDatabase.standard.deleteRule(rule, completion: { rule in
                if rule == nil {
                    DispatchQueue.main.async {
                        self.currentRules.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        if self.currentRules.isEmpty {
                            self.noRulesLabel.isHidden = false
                        }
                    }
                }
            })
        }
        navigationController?.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    func editRule(_ rule: Rule) {
        let ruleEditor = RuleEditorViewController()
        ruleEditor.currentRule = rule
        navigationController?.pushViewController(ruleEditor, animated: true)
    }
}
