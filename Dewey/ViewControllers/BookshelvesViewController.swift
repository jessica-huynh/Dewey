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
    var didEditBookshelves = false
    var inEditMode = false
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent && didEditBookshelves {
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
    }
    
    @IBAction func editTapped(_ sender: Any) {
        didEditBookshelves = true
        tableView.isEditing = !tableView.isEditing
        inEditMode = tableView.isEditing
        editButton.title = tableView.isEditing ? "Done" : "Edit"
    
        if inEditMode {
            tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
        } else {
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddBookshelf", let controller = segue.destination as? AddBookshelfViewController {
            controller.delegate = self
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return inEditMode ? 0 : 1 }
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 { return false }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        storageManager.bookshelves.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        didEditBookshelves = true
    }
}

// MARK: - Add Bookshelf Delegate
extension BookshelvesViewController: AddBookshelfViewControllerDelegate {
    func addBookshelvesViewController(_ controller: AddBookshelfViewController, didAddBookshelfWith name: String) {
        storageManager.bookshelves.append(Bookshelf(name: name))
        tableView.reloadData()
        NotificationCenter.default.post(name: .updatedBookshelves, object: self)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let updatedBookshelves = Notification.Name("updatedBookshelves")
}
