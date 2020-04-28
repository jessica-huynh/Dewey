//
//  BookshelvesViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-28.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookshelvesViewController: UITableViewController {
    let storageManager = StorageManager.instance
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addBookshelf(_ sender: Any) {
    }
    
    @IBAction func editTapped(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        editButton.title = tableView.isEditing ? "Done" : "Edit"
        tableView.reloadData()

        if !tableView.isEditing {
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.isEditing ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return 1 }
        return storageManager.bookshelves.count
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "AddBookshelfCell")!
        }
        
        let bookshelf = storageManager.bookshelves[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookshelfCell", for: indexPath)
        cell.textLabel?.text = bookshelf.name
        cell.detailTextLabel?.text = "\(bookshelf.books.count) books"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedBookshelf = storageManager.bookshelves[sourceIndexPath.row]
        storageManager.bookshelves.remove(at: sourceIndexPath.row)
        storageManager.bookshelves.insert(movedBookshelf, at: destinationIndexPath.row)
    }

}

// MARK: - Notification Names
extension Notification.Name {
    static let updatedBookshelves = Notification.Name("updatedBookshelves")
}
