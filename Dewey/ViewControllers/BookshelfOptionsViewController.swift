//
//  BookshelfOptionsViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-30.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookshelfOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var storageManager = StorageManager.instance
    var bookshelfIndexToDisable: Int = -1
    var delegate: BookshelfOptionsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookshelfCell")
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageManager.bookshelves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookshelfCell", for: indexPath)
        cell.textLabel?.textColor = indexPath.row == bookshelfIndexToDisable ? UIColor.gray : UIColor.black
        cell.textLabel?.text = storageManager.bookshelves[indexPath.row].name
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.bookshelfOptionsViewController(self, didSelectBookshelfAt: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == bookshelfIndexToDisable ? nil : indexPath
    }
}

protocol BookshelfOptionsViewControllerDelegate : class {
    func bookshelfOptionsViewController(_ controller: BookshelfOptionsViewController, didSelectBookshelfAt index: Int)
}

