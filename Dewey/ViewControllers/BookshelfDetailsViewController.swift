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
    var bookshelfIndex: Int!
    var didEditBookshelf = false
    var didSort = false
    
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
        createToolbar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSortDropDownTap(gesture:)))
        sortDropdownIcon.addGestureRecognizer(tap)
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
        sortTextField.textColor = sortTextField.isEnabled ? UIColor.black : UIColor.darkGray
        sortDropdownIcon.isUserInteractionEnabled = sortTextField.isEnabled
    }
    
    @objc func handleSortDropDownTap(gesture: UITapGestureRecognizer) {
        sortTextField.becomeFirstResponder()
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
    
    // MARK: - Sort Picker Setup
    func setupPicker() {
        picker.delegate = self
        picker.backgroundColor = .white
        sortTextField.inputView = picker
    }
    
    func createToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.finishedPicking))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        sortTextField.inputAccessoryView = toolBar
    }
    
    @objc func finishedPicking() {
        view.endEditing(true)
        
        if sortOptionPicked != previousSortOptionPicked {
            didSort = true
            previousSortOptionPicked = sortOptionPicked
            
            switch sortOptionPicked {
            case .recent:
                storageManager.bookshelves[bookshelfIndex].books.sort(by: { $0.dateAddedToShelf! > $1.dateAddedToShelf! })
            case .title:
                storageManager.bookshelves[bookshelfIndex].books.sort(by: { $0.title < $1.title })
            case .author:
                storageManager.bookshelves[bookshelfIndex].books.sort(by: { $0.author < $1.author })
            }
            
            tableView.reloadData()
        }
    }
}

extension BookshelfDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageManager.bookshelves[bookshelfIndex].books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing { return }
        
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

// MARK: - Picker View Delegate
extension BookshelfDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerOptions.allCases.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PickerOptions.allCases[row].rawValue.capitalized
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sortTextField.text = PickerOptions.allCases[row].rawValue.uppercased()
        sortOptionPicked = PickerOptions.allCases[row]
    }
}
