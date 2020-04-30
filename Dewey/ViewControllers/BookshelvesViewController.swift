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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedBookshelves(_:)), name: .updatedBookshelves, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if didEditBookshelves {
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func editTapped(_ sender: Any) {
        didEditBookshelves = true
        toggleEditMode()
    }
    
    @IBAction func deleteAllTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Delete All Bookshelves",
                                      message: "Are you sure you want to proceed? This will remove all bookshelves and the books inside them.",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            self.storageManager.bookshelves = []
            self.toggleEditMode()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func toggleEditMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        inEditMode = tableView.isEditing
        editButton.title = tableView.isEditing ? "Done" : "Edit"
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddBookshelf", let controller = segue.destination as? AddBookshelfViewController {
            controller.delegate = self
            return
        }
        
        if segue.identifier == "BookshelfDetails", let controller = segue.destination as? BookshelfDetailsViewController {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.bookshelfIndex = indexPath.row
            }
        }
    }
    
    @objc func onUpdatedBookshelves(_ notification:Notification) {
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return (inEditMode && storageManager.bookshelves.isEmpty) ? 0 : 1 }
        return storageManager.bookshelves.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return inEditMode ? tableView.dequeueReusableCell(withIdentifier: "DeleteAllCell")! : tableView.dequeueReusableCell(withIdentifier: "AddBookshelfCell")!
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
