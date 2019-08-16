//
//  AttributesTableViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/23/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol AttributesTableViewDelegate: AnyObject {
    func selectedAttribute(_ attribute: Attribute?)
}

class AttributesTableViewController: UITableViewController {
    var game: Game
    var attributes: [Attribute] = []
    weak var delegate: AttributesTableViewDelegate?

    // MARK: Initialization

    init(for game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Attributes"

        tableView.register(UINib(nibName: "AttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "attributeCell")

        let addButton = UIBarButtonItem(title: "Create New", style: .plain, target: self, action: #selector(addAttribute))
        navigationItem.rightBarButtonItem = addButton

        loadAttributes()
    }

    fileprivate func loadAttributes() {
        attributes = game.attributes?.allObjects as? [Attribute] ?? []
        tableView.reloadData()
    }

    // MARK: - Table View

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return attributes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "attributeCell",
            for: indexPath
        ) as? AttributeTableViewCell,
            let attribute = attributes.item(at: indexPath.row) else { fatalError() }
        cell.attribute = attribute
        cell.delegate = self
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let attribute = attributes.item(at: indexPath.row) else { return }
        delegate?.selectedAttribute(attribute)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}

// MARK: - Activities

extension AttributesTableViewController: AttributeTableViewCellDelegate {
    @objc fileprivate func addAttribute() {
        let actionSheet = UIAlertController(title: "Create Attribute", message: "Name this new attribute", preferredStyle: .alert)
        actionSheet.addTextField { textField in
            textField.autocapitalizationType = .words
            textField.placeholder = "Attribute name..."
        }

        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = actionSheet.textFields?.first?.text, !text.isEmpty else { return }
            self.game.createAttribute(text, completion: { attribute in
                guard let attribute = attribute else { return }
                self.attributes.insert(attribute, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            })
        }
        actionSheet.addAction(okButton)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)

        present(actionSheet, animated: true)
        actionSheet.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    func deleteAttribute(_ attribute: Attribute) {
        let indexPath = IndexPath(row: attributes.firstIndex(of: attribute)!, section: 0)
        let alert = UIAlertController.createCancelableAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this attribute? Any Consequences or Rules with this attribute assigned will be set to NULL.",
            primaryActionTitle: "Delete"
        ) { _ in
            attribute.delete(completion: { deletedAttribute in
                if deletedAttribute == nil {
                    self.attributes.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        }
        navigationController?.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }
}
