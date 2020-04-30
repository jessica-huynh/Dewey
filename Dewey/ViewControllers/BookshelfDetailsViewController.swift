//
//  BookshelfDetailsViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-29.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookshelfDetailsViewController: UIViewController {
    var storageManager = StorageManager.instance
    var bookshelfIndex: Int!
    var didEditBookshelf = false
    var didSort = false
    
    var atLeastOneRowSelected = false {
        didSet {
            if oldValue != atLeastOneRowSelected {
                if atLeastOneRowSelected { editBar.enableActions() }
                else { editBar.disableActions() }
            }
        }
    }
    var allRowsSelected = false {
        didSet {
            if oldValue != allRowsSelected {
                editBar.switchSelectAllButton(to: allRowsSelected ? .deselectAll : .selectAll)
            }
        }
    }
    
    lazy var editBar: BookshelfEditBarView  = {
        var editBar = BookshelfEditBarView(frame: CGRect(x: view.center.x - editBarWidth/2,
                                                         y: view.bounds.height - editBarHeight - editBarBottomPadding,
                                                         width: editBarWidth,
                                                         height: editBarHeight))
        editBar.delegate = self
        editBar.disableActions()
        editBar.alpha = 0
        view.addSubview(editBar)
        return editBar
    }()
    
    let editBarHeight: CGFloat = 48
    let editBarWidth: CGFloat = 228
    let editBarBottomPadding: CGFloat = 50
    
    let picker: UIPickerView = UIPickerView()
    enum PickerOptions: String, CaseIterable {
        case recent, title, author
    }
    var sortOptionPicked = PickerOptions.allCases.first!
    var previousSortOptionPicked = PickerOptions.allCases.first!
    
    @IBOutlet weak var navBarTitle: UITextField!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortTextField: UITextField!
    @IBOutlet weak var sortDropdownIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bookDetailsCell = UINib(nibName: "BookDetailsTableViewCell", bundle: nil)
        tableView.register(bookDetailsCell, forCellReuseIdentifier: "BookDetailsCell")
        
        navBarTitle.isEnabled = false
        navBarTitle.text = storageManager.bookshelves[bookshelfIndex].name
        
        setupPicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if didSort {
            // Resort back by most recently added
            storageManager.bookshelves[bookshelfIndex].books.sort(by: { $0.dateAddedToShelf! > $1.dateAddedToShelf! })
        }
        
        if didEditBookshelf {
            if !navBarTitle.text!.isEmpty {
                storageManager.bookshelves[bookshelfIndex].name = navBarTitle.text!
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
        if !tableView.isEditing {
            storageManager.bookshelves[bookshelfIndex].name = navBarTitle.text!
        }
        
        sortTextField.isEnabled = !tableView.isEditing
        sortTextField.textColor = sortTextField.isEnabled ? UIColor.black : UIColor.gray
        sortDropdownIcon.isUserInteractionEnabled = sortTextField.isEnabled
        
        if tableView.isEditing { showEditBar() }
        else { hideEditBar() }
    }
    
    func updateRowSelectionStatus() {
        let numberOfSelectedRows = tableView.indexPathsForSelectedRows?.count ?? 0
        atLeastOneRowSelected = numberOfSelectedRows > 0
        
        let totalBooks = storageManager.bookshelves[bookshelfIndex].books.count
        allRowsSelected = numberOfSelectedRows == totalBooks
    }
}

// MARK: - Table View Delegate
extension BookshelfDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageManager.bookshelves[bookshelfIndex].books.count
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing { updateRowSelectionStatus() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateRowSelectionStatus()
            return
        }
        
        let bookViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        bookViewController.book = storageManager.bookshelves[bookshelfIndex].books[indexPath.row]
        navigationController?.pushViewController(bookViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsCell", for: indexPath) as! BookDetailsTableViewCell
        cell.configure(book: storageManager.bookshelves[bookshelfIndex].books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        storageManager.bookshelves[bookshelfIndex].books.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        didEditBookshelf = true
    }
}
