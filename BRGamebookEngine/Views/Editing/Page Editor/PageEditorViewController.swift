//
//  PageEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class PageEditorViewController: UIViewController {
    var currentGame: Game?
    var currentPage: Page? {
        didSet {
            loadContent()
        }
    }

    var previousPage: Page?
    var currentDecisions: [Decision]?
    var currentConsequences: [Consequence]?

    @IBOutlet var textView: UITextView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PageEditorDecisionTableViewCell", bundle: nil), forCellReuseIdentifier: "decisionCell")
        tableView.register(UINib(nibName: "PageEditorConsequenceTableViewCell", bundle: nil), forCellReuseIdentifier: "consequenceCell")

        let pagesButton = UIBarButtonItem(title: "Pages", style: .plain, target: self, action: #selector(loadPages))
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAddActionSheet))
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goToPreviousPage))
        let attributesButton = UIBarButtonItem(title: "Attrs", style: .plain, target: self, action: #selector(loadAttributes))

        navigationItem.rightBarButtonItems = [addButton, pagesButton, attributesButton, backButton]

        let exitButton = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitAction))
        let helpButton = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(helpAction))

        navigationItem.leftBarButtonItems = [exitButton, helpButton]

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction)),
        ]
        textView.inputAccessoryView = toolbar

        textView.allowsEditingTextAttributes = true

        if let game = currentGame {
            title = "Editing: " + game.name
            if currentPage == nil {
                coreDataStore.fetchFirstPage(for: game) { page in
                    self.currentPage = page
                }
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        loadContent()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        super.updateViewConstraints()
        tableViewHeightConstraint?.constant = tableView.contentSize.height
    }

    fileprivate func loadContent() {
        guard let page = currentPage else { return }
        DispatchQueue.main.async {
            self.textView.attributedText = page.content
            if let decisions = page.decisions?.allObjects as? [Decision] {
                self.currentDecisions = decisions
            }
            if let consequences = page.consequences?.allObjects as? [Consequence] {
                self.currentConsequences = consequences
            }
            self.tableView.reloadData()
            self.viewWillLayoutSubviews()
        }
    }

    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc func helpAction() {
        navigationController?.pushViewController(HelpViewController(), animated: true)
    }

    @objc func doneAction() {
        textView.resignFirstResponder()
        saveContent()
    }

    @objc func goToPreviousPage() {
        let page = currentPage
        currentPage = previousPage
        previousPage = page
    }

    @objc fileprivate func loadPages() {
        let pagesView = PagesTableViewController()
        pagesView.currentGame = currentGame
        pagesView.delegate = self
        navigationController?.pushViewController(pagesView, animated: true)
    }

    @objc fileprivate func loadAttributes() {
        let attributesView = AttributesTableViewController()
        attributesView.currentGame = currentGame
        navigationController?.pushViewController(attributesView, animated: true)
    }

    fileprivate func saveContent() {
        guard let page = currentPage else { return }
        page.content = textView.attributedText
        coreDataStore.saveContext()
    }

    @objc fileprivate func showAddActionSheet() {
        let actionSheet = UIAlertController(title: "Add", message: nil, preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)

        let addConsequenceButton = UIAlertAction(title: "Consequence", style: .default) { _ in
            coreDataStore.createConsequence(for: self.currentPage!, attribute: nil, type: nil, amount: 0, completion: { _ in
                self.loadContent()
            })
        }
        actionSheet.addAction(addConsequenceButton)

        let addDecisionButton = UIAlertAction(title: "Decision", style: .default) { _ in
            coreDataStore.createPage(
                for: self.currentGame!,
                content: NSAttributedString(
                    string: "A decision will lead to this new page...",
                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
                ),
                type: nil,
                completion: { page in
                    if let destination = page {
                        coreDataStore.createDecision(
                            for: self.currentPage!,
                            content: NSAttributedString(
                                string: "A decision to be made...",
                                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
                            ),
                            destination: destination,
                            completion: { _ in
                                self.loadContent()
                            }
                        )
                    }
                }
            )
        }
        actionSheet.addAction(addDecisionButton)

        present(actionSheet, animated: true)
    }
}

extension PageEditorViewController: UITextViewDelegate {
    func textViewDidEndEditing(_: UITextView) {
        saveContent()
    }
}

extension PageEditorViewController: PagesTableViewDelegate {
    func deletedPage(_ page: Page) {
        if currentPage == page, let currentGame = self.currentGame {
            if previousPage != nil {
                currentPage = previousPage
            } else {
                coreDataStore.fetchFirstPage(for: currentGame, completion: { page in
                    self.currentPage = page
                })
            }
        }
    }

    func selectedPage(_ page: Page) {
        previousPage = currentPage
        currentPage = page
    }
}

extension PageEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Decisions"
        }
        return "Consequences"
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentDecisions?.count ?? 0
        }
        return currentConsequences?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "decisionCell", for: indexPath)
            cell.textLabel?.text = currentDecisions?[indexPath.row].content.string
            return cell
        }
        guard let consequence = currentConsequences?.item(at: indexPath.row) else { fatalError() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "consequenceCell", for: indexPath)
        cell.selectionStyle = .none

        let attribute = consequence.attribute?.name ?? "NULL"
        let value = consequence.amount
        switch consequence.type {
        case .set:
            cell.textLabel?.text = "\(attribute): Set to \(value)"
        case .add:
            cell.textLabel?.text = "\(attribute): Add \(value)"
        case .subtract:
            cell.textLabel?.text = "\(attribute): Subtract \(value)"
        case .multiply:
            cell.textLabel?.text = "\(attribute): Multiply by \(value)"
        }
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let decision = currentDecisions?.item(at: indexPath.row) else { return }
            previousPage = currentPage
            currentPage = decision.destination
        }
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        view.tintColor = .darkText
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .white
        let view = UIView()
        view.backgroundColor = .black
        header.backgroundView = view
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    // MARK: - Edit Actions

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            // Decision
            let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _, indexPath in
                guard let decision = self.currentDecisions?.item(at: indexPath.row) else { return }
                let decisionEditor = DecisionEditorViewController()
                decisionEditor.currentDecision = decision
                self.navigationController?.pushViewController(decisionEditor, animated: true)
            }

            editAction.backgroundColor = .black

            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
                guard let decision = self.currentDecisions?.item(at: indexPath.row) else { return }
                // TODO: We should confirm deletion here before deleting.
                coreDataStore.deleteDecision(decision, completion: { decision in
                    if decision == nil {
                        DispatchQueue.main.async {
                            self.currentDecisions?.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }

            return [editAction, deleteAction]
        } else {
            // Consequence
            let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _, indexPath in
                guard let consequence = self.currentConsequences?.item(at: indexPath.row) else { return }
                let consequenceEditor = ConsequenceEditorViewController()
                consequenceEditor.currentConsequence = consequence
                self.navigationController?.pushViewController(consequenceEditor, animated: true)
            }
            editAction.backgroundColor = .black

            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
                guard let consequence = self.currentConsequences?.item(at: indexPath.row) else { return }
                coreDataStore.deleteConsequence(consequence, completion: { consequence in
                    if consequence == nil {
                        DispatchQueue.main.async {
                            self.currentConsequences?.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }
            return [editAction, deleteAction]
        }
    }
}
