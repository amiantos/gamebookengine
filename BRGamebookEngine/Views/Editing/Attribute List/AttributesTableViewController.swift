//
//  AttributesTableViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/23/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class AttributesTableViewController: UITableViewController {
    var currentGame: Game?
    var attributes: [Attribute] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Attributes"

        tableView.register(UINib(nibName: "AttributeTableViewCell", bundle: nil), forCellReuseIdentifier: "attributeCell")

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAttribute))
        navigationItem.rightBarButtonItem = addButton

        loadAttributes()
    }

    @objc fileprivate func addAttribute() {
        let actionSheet = UIAlertController(title: "Name", message: "Name your new attribute", preferredStyle: .alert)
        actionSheet.addTextField { textField in
            textField.placeholder = "Attribute name..."
        }

        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = actionSheet.textFields?.first?.text, !text.isEmpty, let game = self.currentGame else { return }
            coreDataStore.createAttribute(for: game, name: text, completion: { attribute in
                guard let attribute = attribute else { return }
                DispatchQueue.main.async {
                    self.attributes.append(attribute)
                    self.tableView.reloadData()
                }
            })
        }
        actionSheet.addAction(okButton)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelButton)

        present(actionSheet, animated: true)
    }

    fileprivate func loadAttributes() {
        if let game = currentGame {
            coreDataStore.fetchAllAttributes(for: game) { attributes in
                guard let attributes = attributes else { return }
                DispatchQueue.main.async {
                    self.attributes = attributes
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return attributes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attributeCell", for: indexPath)

        cell.textLabel?.text = attributes[indexPath.row].name

        return cell
    }
}
