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
    var bookshelfToDisable: Bookshelf?
    var delegate: BookshelfOptionsViewControllerDelegate?
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "#EEECE4")
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookshelfCell")
        view.addSubview(tableView)
        
        let noBookshelvesCell = UINib(nibName: "NoBookshelvesFoundTableViewCell", bundle: nil)
        tableView.register(noBookshelvesCell, forCellReuseIdentifier: "NoBookshelvesCell")
        
        setupNavigationButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedBookshelves(_:)), name: .updatedBookshelves, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        let addBookshelfButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBookshelf))
        navigationItem.setRightBarButton(addBookshelfButton, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
    
    @objc func cancelTapped(_ sender: Any) {
        dismiss()
    }
    
    @objc func addBookshelf(_ sender: Any) {
        let addBookshelfViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddBookshelfViewController") as! AddBookshelfViewController
        navigationController?.pushViewController(addBookshelfViewController, animated: true)
    }
    
    @objc func onUpdatedBookshelves(_ notification:Notification) {
        tableView.reloadData()
    }
    
    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storageManager.bookshelves.isEmpty ? 1 : storageManager.bookshelves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if storageManager.bookshelves.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "NoBookshelvesCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookshelfCell", for: indexPath)
        cell.textLabel?.textColor =
            (storageManager.bookshelves[indexPath.row].id == bookshelfToDisable?.id) ? UIColor.gray : UIColor.black
        cell.textLabel?.text = storageManager.bookshelves[indexPath.row].name
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.bookshelfOptionsViewController(self, didSelectBookshelfAt: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if storageManager.bookshelves.isEmpty ||
            (storageManager.bookshelves[indexPath.row] == bookshelfToDisable) {
            return nil
        }
        return indexPath
    }
}

// MARK: - Protocol
protocol BookshelfOptionsViewControllerDelegate : class {
    func bookshelfOptionsViewController(_ controller: BookshelfOptionsViewController, didSelectBookshelfAt index: Int)
}
