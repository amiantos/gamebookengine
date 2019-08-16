//
//  PagesTableViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol PagesTableViewDelegate: AnyObject {
    func selectedPage(_ page: Page)
    func deletedPage(_ page: Page)
}

class PagesTableViewController: UITableViewController {
    var currentGame: Game?
    var pages: [Page] = []
    weak var delegate: PagesTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pages"

        tableView.register(UINib(nibName: "PageTableViewCell", bundle: nil), forCellReuseIdentifier: "pageCell")

        // MARK: - Set up Add Button

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPage))
        navigationItem.rightBarButtonItem = addButton

        loadPages()
    }

    @objc fileprivate func addPage() {
        print("Add Page")
    }

    fileprivate func loadPages() {
        if let currentGame = currentGame {
            coreDataStore.fetchAllPages(for: currentGame, completion: { pages in
                guard let pages = pages else { return }
                DispatchQueue.main.async {
                    self.pages = pages
                    self.tableView.reloadData()
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return pages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pageCell", for: indexPath)

        cell.textLabel?.text = pages[indexPath.row].content?.string
        cell.detailTextLabel?.text = pages[indexPath.row].uuid?.uuidString

        return cell
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Send selected page to delegate
        guard let page = pages.item(at: indexPath.row) else { return }
        delegate?.selectedPage(page)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Delete Page
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            guard let page = self.pages.item(at: indexPath.row) else { return }
            // TODO: We should confirm deletion here before deleting.
            coreDataStore.deletePage(page, completion: { deletedPage in
                if deletedPage == nil {
                    self.pages.remove(at: indexPath.row)
                    self.delegate?.deletedPage(page)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        }
        return [deleteAction]
    }
}
