//
//  AddBookshelfViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-28.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AddBookshelfViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
        textField.becomeFirstResponder()
        addTapToResignFirstResponder()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        textField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        StorageManager.instance.addBookshelf(with: textField.text!)
        NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Text Field Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneButton.isEnabled = false
        return true
    }
}
