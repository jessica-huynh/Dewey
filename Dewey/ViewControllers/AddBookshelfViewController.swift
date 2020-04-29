//
//  AddBookshelfViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-28.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AddBookshelfViewController: UIViewController, UITextFieldDelegate {
    var delegate: AddBookshelfViewControllerDelegate?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
        textField.becomeFirstResponder()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        delegate?.addBookshelvesViewController(self, didAddBookshelfWith: textField.text!)
        dismiss(animated: true, completion: nil)
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

protocol AddBookshelfViewControllerDelegate: class {
    func addBookshelvesViewController(_ controller: AddBookshelfViewController, didAddBookshelfWith name: String)
}
