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
    var spinnerView: UIView!
    var isLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView = createSpinnerView(with: UIColor(hexString: "#EEECE4"))
        navigationController?.navigationBar.shadowImage = UIImage()
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedBookshelves(_:)), name: .updatedBookshelves, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onBeganFetchUpdates), name: .beganFetchUpdates, object: nil)
        
        let bookshelfSectionHeader = UINib(nibName: "BookshelfSectionHeaderView", bundle: nil)
        tableView.register(bookshelfSectionHeader, forHeaderFooterViewReuseIdentifier: "BookshelfSectionHeader")
        
        addTapToResignFirstResponder(with: #selector(resetSearchBarIfNeeded))
        
        if storageManager.isFetchingUpdates {
            isLoading = true
            showSpinner(spinnerView: spinnerView)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BookDetails" {
            if let bookCollectionCell = sender as? BookCollectionViewCell, let controller = segue.destination as? BookViewController {
                controller.book = bookCollectionCell.book
                controller.originatingBookshelf = bookCollectionCell.originatingBookshelf
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
        if isLoading {
            isLoading = false
            removeSpinner(spinnerView: spinnerView)
        }
        tableView.reloadData()
    }
    
    @objc func onBeganFetchUpdates() {
        isLoading = true
        showSpinner(spinnerView: spinnerView)
        
        // Dismiss all view controllers
        navigationController?.popToRootViewController(animated: false)
        
        for scene in UIApplication.shared.connectedScenes {
            (scene as! UIWindowScene).windows.forEach {
                if $0.isKeyWindow {
                    $0.rootViewController?.dismiss(animated: false, completion: nil)
                    return
                }
            }
        }
    }
}

// MARK: - Table View Data Source
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return storageManager.bookshelves.isEmpty ? 2 : storageManager.bookshelves.count + 1
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
        
        if storageManager.bookshelves.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "NoBookshelvesCell")!
        }
        
        let bookshelf = storageManager.bookshelves[indexPath.section - 1]
        if bookshelf.books.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyBookshelfCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookshelfCell", for: indexPath) as! BookshelfTableViewCell
        cell.bookshelf = bookshelf
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 || storageManager.bookshelves.isEmpty ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || storageManager.bookshelves.isEmpty { return nil }
        
        let bookshelf = storageManager.bookshelves[section - 1]
        let bookshelfSectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BookshelfSectionHeader") as! BookshelfSectionHeaderView
        bookshelfSectionHeader.delegate = self
        bookshelfSectionHeader.bookshelf = bookshelf
        bookshelfSectionHeader.bookshelfName.text = bookshelf.name
        return bookshelfSectionHeader
    }
}

// MARK: - Search Bar Delegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "SearchResults", sender: self)
        resetSearchBarIfNeeded()
    }
}

// MARK: - Bookshelf Section View Delegate
extension HomeViewController: BookshelfSectionHeaderViewDelegate {
    func bookshelfSectionHeaderView(_ bookshelfSectionHeaderView: BookshelfSectionHeaderView, didTapSeeAll button: UIButton) {
        let bookshelfDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookshelfDetailsViewController") as! BookshelfDetailsViewController
        bookshelfDetailsViewController.bookshelf = bookshelfSectionHeaderView.bookshelf
        navigationController?.pushViewController(bookshelfDetailsViewController, animated: true)
    }
    
    
}
