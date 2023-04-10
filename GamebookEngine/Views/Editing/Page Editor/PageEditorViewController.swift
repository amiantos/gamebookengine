//
//  PageEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SwiftUI
import UIKit

protocol PageEditorDelegate: AnyObject {
    func selectedPage(_ page: Page)
    func deletedPage(_ page: Page)
    func setFirstPage(_ page: Page)
}

class PageEditorViewController: UIViewController {
    var currentGame: Game?
    var currentPage: Page?

    var addButton = UIBarButtonItem()
    var backButton = UIBarButtonItem()
    var mapButton = UIBarButtonItem()
    var helpButton = UIBarButtonItem()

    var pageScene: PageEditorDelegate?

    var previousPage: Page? {
        didSet {
            if previousPage != nil {
                backButton.isEnabled = true
            }
        }
    }

    var currentDecisions: [Decision] = []
    var currentConsequences: [Consequence] = []
    @IBOutlet var pageTypeSegmentedControl: UISegmentedControl!
    @IBAction func pageTypeValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            guard let currentPage = currentPage, let currentGame = currentGame else { return }
            let alert = UIAlertController.createCancelableAlert(
                title: "Warning!",
                message: "This will replace the current first page with this page. It will not delete any pages or otherwise modify your game. Continue?",
                primaryActionTitle: "Set to First Page"
            ) { _ in
                GameDatabase.standard.fetchFirstPage(for: currentGame, completion: { page in
                    page?.setType(to: .none)
                })
                currentPage.setType(to: .first)
                self.showOrHideWarningLabel()
                self.loadContent()
                self.pageScene?.setFirstPage(currentPage)
            }
            navigationController?.present(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor(named: "text") ?? .darkGray
        case 2:
            let alert = UIAlertController.createCancelableAlert(
                title: "Warning!",
                message: "Turning a page into an ending will remove any decisions and consequences on the page. Are you sure?",
                primaryActionTitle: "Set to Ending"
            ) { _ in
                self.currentPage?.setType(to: .ending)
                self.showOrHideWarningLabel()
                self.loadContent()
            }
            navigationController?.present(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor(named: "text") ?? .darkGray
        default:
            currentPage?.setType(to: .none)
        }
        showOrHideWarningLabel()
        loadContent()
    }

    @IBOutlet var textView: UITextView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var warningImage: UIImageView!
    @IBOutlet var warningLabel: UILabel!

    @IBAction func editTextAction(_: UIButton) {
        guard let page = currentPage else { return }
        let textEditor = MarkdownEditorViewController(with: page)
        navigationController?.pushViewController(textEditor, animated: true)
    }

    @IBOutlet var deletePageButton: UIButton!
    @IBAction func deletePage(_: UIButton) {
        guard let page = currentPage else { return }

        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this page? Deleting this page will set any Decisions leading to it to NULL.",
            primaryActionTitle: "Delete"
        ) { _ in
            GameDatabase.standard.deletePage(page, completion: { deletedPage in
                if deletedPage == nil {
                    if self.previousPage != nil {
                        self.currentPage = self.previousPage
                        self.loadContent()
                    } else {
                        GameDatabase.standard.fetchFirstPage(for: self.currentGame!, completion: { page in
                            self.currentPage = page
                            self.loadContent()
                        })
                    }
                }
            })
        }
        navigationController?.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PageEditorDecisionTableViewCell", bundle: nil), forCellReuseIdentifier: "decisionCell")
        tableView.register(UINib(nibName: "PageEditorConsequenceTableViewCell", bundle: nil), forCellReuseIdentifier: "consequenceCell")

        addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAddActionSheet))
        backButton = UIBarButtonItem(title: "Prev Page", style: .plain, target: self, action: #selector(goToPreviousPage))
        helpButton = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .plain, target: self, action: #selector(helpAction))

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.rightBarButtonItems = [addButton, backButton]
        navigationItem.leftBarButtonItems = [helpButton]

        navigationItem.largeTitleDisplayMode = .never

        backButton.isEnabled = false

        title = "Page Editor"

        // Setup link colors in textview
        var linkColor: UIColor = .darkGray
        var underlineColor: UIColor = .lightGray
        if #available(iOS 13.0, *) {
            linkColor = .secondaryLabel
            underlineColor = .quaternaryLabel
        }
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: linkColor,
            NSAttributedString.Key.underlineColor: underlineColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        textView.linkTextAttributes = linkAttributes

        if let game = currentGame {
            if currentPage == nil {
                GameDatabase.standard.fetchFirstPage(for: game) { page in
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
    }

    fileprivate func showOrHideWarningLabel() {
        if currentPage?.needsDecisions ?? false {
            warningImage.isHidden = false
            warningLabel.isHidden = false
        } else {
            warningImage.isHidden = true
            warningLabel.isHidden = true
        }
    }

    fileprivate func loadContent() {
        guard let page = currentPage else { return }
        DispatchQueue.main.async {
            self.pageScene?.selectedPage(page)
            self.textView.attributedText = BRMarkdownParser.standard.convertToAttributedString(
                page.content, with: UIFont.preferredFont(forTextStyle: .callout)
            )
            if let decisions = page.decisions?.array as? [Decision] {
                self.currentDecisions = decisions
            }
            if let consequences = page.consequences?.allObjects as? [Consequence] {
                self.currentConsequences = consequences
            }

            self.showOrHideWarningLabel()

            self.tableView.reloadData()
            self.tableView.setNeedsLayout()
            self.viewWillLayoutSubviews()

            self.pageTypeSegmentedControl.isEnabled = true
            self.deletePageButton.isEnabled = true
            if page.type == .first {
                self.pageTypeSegmentedControl.isEnabled = false
                self.deletePageButton.isEnabled = false
                self.pageTypeSegmentedControl.selectedSegmentIndex = 0
            } else if page.type == .ending {
                self.pageTypeSegmentedControl.selectedSegmentIndex = 2
            } else {
                self.pageTypeSegmentedControl.selectedSegmentIndex = 1
            }

            if page.type == .ending {
                self.addButton.isEnabled = false
            } else {
                self.addButton.isEnabled = true
            }
        }
    }

    @objc func helpAction() {
        let swiftUIViewController = UIHostingController(rootView: HelpView())
        swiftUIViewController.modalPresentationStyle = .pageSheet
//        present(swiftUIViewController, animated: true, completion: nil)
        navigationController?.pushViewController(swiftUIViewController, animated: true)
    }

    @objc func exitAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc func goToPreviousPage() {
        let page = currentPage
        currentPage = previousPage
        previousPage = page
        loadContent()
    }

    @objc fileprivate func showAddActionSheet() {
        let actionSheet = UIAlertController(title: "Add", message: nil, preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)

        let addConsequenceButton = UIAlertAction(title: "Consequence", style: .default) { _ in
            GameDatabase.standard.createConsequence(for: self.currentPage!, attribute: nil, type: nil, amount: 0, completion: { consequence in
                guard let consequence = consequence else { return }
                DispatchQueue.main.async {
                    self.loadContent()
                    self.editConsequence(consequence)
                }
            })
        }
        actionSheet.addAction(addConsequenceButton)

        let addDecisionButton = UIAlertAction(title: "Decision", style: .default) { _ in
            GameDatabase.standard.createPage(
                for: self.currentGame!,
                content: "A decision will lead to this new page...",
                type: .none,
                completion: { page in
                    if let destination = page {
                        GameDatabase.standard.createDecision(
                            for: self.currentPage!,
                            content: "A decision to be made...",
                            destination: destination,
                            completion: { decision in
                                guard let decision = decision else { return }
                                DispatchQueue.main.async {
                                    self.loadContent()
                                    self.editDecision(decision)
                                }
                            }
                        )
                    }
                }
            )
        }
        actionSheet.addAction(addDecisionButton)

        actionSheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(actionSheet, animated: true)
        actionSheet.view.tintColor = UIColor(named: "text") ?? .darkGray
    }
}

extension PageEditorViewController: PagesTableViewDelegate {
    func deletedPage(_ page: Page) {
        if currentPage == page, let currentGame = currentGame {
            if previousPage != nil {
                currentPage = previousPage
            } else {
                GameDatabase.standard.fetchFirstPage(for: currentGame, completion: { page in
                    self.currentPage = page
                    self.loadContent()
                })
            }
        }
    }

    func selectedPage(_ page: Page) {
        previousPage = currentPage
        currentPage = page
        loadContent()
        navigationController?.popViewController(animated: true)
    }
}

extension PageEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0, !currentDecisions.isEmpty {
            return "Decisions"
        } else if section == 1, !currentConsequences.isEmpty {
            return "Consequences"
        } else {
            return nil
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentDecisions.count
        }
        return currentConsequences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "decisionCell",
                for: indexPath
            ) as? PageEditorDecisionTableViewCell,
                let decision = currentDecisions.item(at: indexPath.row) else { fatalError() }
            cell.decision = decision
            cell.delegate = self
            return cell
        }
        guard let consequence = currentConsequences.item(at: indexPath.row),
              let cell = tableView.dequeueReusableCell(
                  withIdentifier: "consequenceCell",
                  for: indexPath
              ) as? PageEditorConsequenceTableViewCell else { fatalError() }
        cell.selectionStyle = .none
        cell.consequence = consequence
        cell.delegate = self
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let decision = currentDecisions.item(at: indexPath.row) else { return }
            previousPage = currentPage
            currentPage = decision.destination
            loadContent()
        }
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        let view = UIView()
        if #available(iOS 13.0, *) {
            header.tintColor = .secondaryLabel
            header.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
            header.textLabel?.textColor = .tertiaryLabel
            view.backgroundColor = UIColor(named: "background")
        } else {
            header.tintColor = .darkText
            header.textLabel?.textColor = .lightGray
            header.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
            view.backgroundColor = UIColor(named: "background")
        }
        header.backgroundView = view
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}

extension PageEditorViewController: PageEditorDecisionTableViewCellDelegate {
    func editDecision(_ decision: Decision) {
        let decisionEditor = DecisionEditorViewController()
        decisionEditor.currentDecision = decision
        navigationController?.pushViewController(decisionEditor, animated: true)
    }

    func deleteDecision(_ decision: Decision) {
        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this decision?",
            primaryActionTitle: "Delete"
        ) { _ in
            let indexPath = IndexPath(row: self.currentDecisions.firstIndex(of: decision)!, section: 0)
            GameDatabase.standard.deleteDecision(decision, completion: { decision in
                if decision == nil {
                    DispatchQueue.main.async {
                        self.currentDecisions.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.showOrHideWarningLabel()
                    }
                }
            })
        }
        navigationController?.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }
}

extension PageEditorViewController: PageEditorConsequenceTableViewCellDelegate {
    func editConsequence(_ consequence: Consequence) {
        let consequenceEditor = ConsequenceEditorViewController()
        consequenceEditor.currentConsequence = consequence
        navigationController?.pushViewController(consequenceEditor, animated: true)
    }

    func deleteConsequence(_ consequence: Consequence) {
        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this consequence?",
            primaryActionTitle: "Delete"
        ) { _ in
            let indexPath = IndexPath(row: self.currentConsequences.firstIndex(of: consequence)!, section: 1)
            GameDatabase.standard.deleteConsequence(consequence, completion: { consequence in
                if consequence == nil {
                    DispatchQueue.main.async {
                        self.currentConsequences.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            })
        }
        navigationController?.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }
}
