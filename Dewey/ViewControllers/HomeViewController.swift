//
//  HomeViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    let storageManager = StorageManager.instance
    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedBookshelves(_:)), name: .updatedBookshelves, object: nil)
        
        addTapToResignFirstResponder(with: #selector(resetSearchBarIfNeeded))
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BookDetails" {
            if let bookCollectionCell = sender as? BookCollectionViewCell, let controller = segue.destination as? BookViewController {
                controller.book = bookCollectionCell.book
            }
        } else if segue.identifier == "SearchResults" {
            if let controller = segue.destination as? SearchResultsViewController {
                controller.searchQuery = searchBar.text
            }
        }
        resetSearchBarIfNeeded()
    }
    
    @objc func resetSearchBarIfNeeded() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            searchBar.text = ""
        }
    }
    
    @objc func onUpdatedBookshelves(_ notification:Notification) {
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return storageManager.bookshelves.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HomeHeaderTableViewCell
            cell.searchBarDelegate = self
            searchBar = cell.searchBar
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookshelfCell", for: indexPath) as! BookshelfTableViewCell
        cell.bookshelf = storageManager.bookshelves[indexPath.section - 1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "" }
        return storageManager.bookshelves[section - 1].name
    }
}

// MARK: - Search Bar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "SearchResults", sender: self)
        resetSearchBarIfNeeded()
    }
}
