//
//  BookshelfDetailsViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-29.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookshelfDetailsViewController: UIViewController, UITextFieldDelegate {
    var storageManager = StorageManager.instance
    var bookshelf: Bookshelf!
    var bookShelfIndex: Int!
    var didEditBookshelf = false
    
    @IBOutlet weak var navBarTitle: UITextField!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bookDetailsCell = UINib(nibName: "BookDetailsTableViewCell", bundle: nil)
        tableView.register(bookDetailsCell, forCellReuseIdentifier: "BookDetailsCell")
        
        navBarTitle.isEnabled = false
        navBarTitle.text = bookshelf.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent && didEditBookshelf {
            storageManager.bookshelves[bookShelfIndex].books = bookshelf.books
            if !navBarTitle.text!.isEmpty {
                storageManager.bookshelves[bookShelfIndex].name = navBarTitle.text!
            }
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
    }
    
    @IBAction func editTapped(_ sender: Any) {
        didEditBookshelf = true
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.title = tableView.isEditing ? "Done" : "Edit"
        
        navBarTitle.isEnabled = tableView.isEditing
        navBarTitle.borderStyle = tableView.isEditing ? .roundedRect : .none
    }
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navBarTitle.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        editButton.isEnabled = !newText.isEmpty
        return true
    }
}

extension BookshelfDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookshelf.books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing { return }
        
        let bookViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        bookViewController.book = bookshelf.books[indexPath.row]
        navigationController?.pushViewController(bookViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsCell", for: indexPath) as! BookDetailsTableViewCell
        cell.configure(book: bookshelf.books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        bookshelf.books.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        didEditBookshelf = true
    }
}
