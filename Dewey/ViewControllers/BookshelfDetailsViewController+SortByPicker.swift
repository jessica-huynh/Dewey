//
//  BookshelfDetailsViewController+SortByPicker.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-30.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension BookshelfDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Sort Picker Setup
    func setupPicker() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSortDropDownTap(gesture:)))
        sortDropdownIcon.addGestureRecognizer(tap)
        
        picker.delegate = self
        picker.backgroundColor = .white
        sortTextField.inputView = picker
        createToolbar()
    }
    
    func createToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.finishedPicking))
        doneButton.tintColor = .darkGray
        
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
                bookshelf.books.sort(by: { $0.dateAddedToShelf > $1.dateAddedToShelf })
            case .title:
                bookshelf.books.sort(by: { $0.title < $1.title })
            case .author:
                bookshelf.books.sort(by: { $0.author < $1.author })
            }
            
            tableView.reloadData()
        }
    }
    
    @objc func handleSortDropDownTap(gesture: UITapGestureRecognizer) {
        sortTextField.becomeFirstResponder()
    }

    // MARK: - Picker View Delegate
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
