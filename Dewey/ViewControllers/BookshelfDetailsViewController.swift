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
    var bookshelf: Bookshelf!
    var didEditBookshelf = false
    var didSort = false
    
    var noBooks = false {
        didSet {
            if oldValue != noBooks {
                if noBooks { editBar.disableSelectAllButton() }
                else { editBar.enableSelectAllButton() }
            }
        }
    }
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
        navBarTitle.placeholder = bookshelf.name
        navBarTitle.text = bookshelf.name
        
        setupPicker()
        addTapToResignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if didSort {
            // Resort back by most recently added
            bookshelf.books.sort(by: { $0.dateAddedToShelf! > $1.dateAddedToShelf! })
        }
        
        if didEditBookshelf {
            if !navBarTitle.text!.isEmpty {
                bookshelf.name = navBarTitle.text!
            }
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
    }
    
    // MARK: - Actions
    @IBAction func editTapped(_ sender: Any) {
        didEditBookshelf = true
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.title = tableView.isEditing ? "Done" : "Edit"
        
        navBarTitle.isEnabled = tableView.isEditing
        navBarTitle.borderStyle = tableView.isEditing ? .roundedRect : .none
        if !tableView.isEditing {
            bookshelf.name = navBarTitle.text!.isEmpty ? bookshelf.name : navBarTitle.text!
            navBarTitle.text = bookshelf.name
        }
        
        sortTextField.isEnabled = !tableView.isEditing
        sortTextField.textColor = sortTextField.isEnabled ? UIColor.black : UIColor.gray
        sortDropdownIcon.isUserInteractionEnabled = sortTextField.isEnabled
        
        if tableView.isEditing { showEditBar() }
        else { hideEditBar() }
    }
    
    func deleteBooksAt(indexPaths: [IndexPath]) {
        if allRowsSelected {
            storageManager.removeAllBooks(from: bookshelf)
            tableView.reloadData()
            editBar.switchSelectAllButton(to: .selectAll)
        } else {
            let indexPaths = indexPaths.sorted(by: { $0.row > $1.row })
            for indexPath in indexPaths {
                storageManager.removeBook(at: indexPath.row, from: bookshelf)
            }
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        updateEditBarButtons()
    }
}

// MARK: - Table View Delegate
extension BookshelfDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookshelf.books.isEmpty ? 1 : bookshelf.books.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if bookshelf.books.isEmpty { return nil }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing { updateEditBarButtons() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateEditBarButtons()
            return
        }
        
        let bookViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        bookViewController.book = bookshelf.books[indexPath.row]
        bookViewController.originatingBookshelf = bookshelf
        navigationController?.pushViewController(bookViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bookshelf.books.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "NoBooksCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsCell", for: indexPath) as! BookDetailsTableViewCell
        cell.configure(book: bookshelf.books[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if bookshelf.books.isEmpty { return false }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        storageManager.removeBook(at: indexPath.row, from: bookshelf)
        tableView.deleteRows(at: [indexPath], with: .fade)
        didEditBookshelf = true
    }
}

// MARK: - Text field delegate
extension BookshelfDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navBarTitle.resignFirstResponder()
        return true
    }
}
