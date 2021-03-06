//
//  SearchResultsViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-28.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var searchQuery: String!
    var searchResults: [Book] = []
    var isLoading: Bool = false {
        didSet { tableView.reloadData() }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.text = searchQuery
        searchBar.delegate = self
        
        let bookDetailsCell = UINib(nibName: "BookDetailsTableViewCell", bundle: nil)
        tableView.register(bookDetailsCell, forCellReuseIdentifier: "BookDetailsCell")
        let loadingCell = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.register(loadingCell, forCellReuseIdentifier: "LoadingCell")
        
        addTapToResignFirstResponder()
        performSearch()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func performSearch() {
        isLoading = true
        iTunesSearchAPI.request(for: .search(query: searchBar.text!)) {
            [weak self] response in
            guard let self = self else { return }
            
            let searchResponse = try SearchResponse(data: response.data)
            self.searchResults = searchResponse.results
            self.tableView.reloadData()
            self.isLoading = false
        }
    }
    
    // MARK: - Table View Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.isEmpty || isLoading ? 1 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.isEmpty || isLoading { return nil }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UITableViewCell.darkerBackgroundView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        bookViewController.book = searchResults[indexPath.row]
        let navController = UINavigationController.custom(with: bookViewController)
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        
        if searchResults.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "NoResultsCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsCell", for: indexPath) as! BookDetailsTableViewCell
        cell.configure(book: searchResults[indexPath.row])
        return cell
    }

    // MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
        searchBar.resignFirstResponder()
    }
}
