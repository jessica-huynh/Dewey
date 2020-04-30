//
//  BookshelfDetailsViewController+Edit.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-30.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension BookshelfDetailsViewController: BookshelfEditBarViewDelegate {
    // MARK: Edit Bar Helpers
    func showEditBar() {
        atLeastOneRowSelected = false
        allRowsSelected = false
        UIView.animate(withDuration: 0.5) {
            self.editBar.alpha = 1
            self.editBar.isHidden = false
        }
    }
    
    func hideEditBar() {
        UIView.animate(withDuration: 0.5,
                       animations: { self.editBar.alpha = 0 },
                       completion: { _ in self.editBar.isHidden = true })
    }
    
    func presentBookshelfOptionsViewController() {
        let viewController = BookshelfOptionsViewController(nibName: "BookshelfOptionsViewController", bundle: nil)
        viewController.delegate = self
        viewController.bookshelfIndex = bookshelfIndex
        present(viewController, animated: true, completion: nil)
    }
    
    func updateEditBarButtons() {
        let numberOfSelectedRows = tableView.indexPathsForSelectedRows?.count ?? 0
        atLeastOneRowSelected = numberOfSelectedRows > 0
        
        let totalBooks = storageManager.bookshelves[bookshelfIndex].books.count
        allRowsSelected = numberOfSelectedRows == totalBooks
        
        noBooks = storageManager.bookshelves[bookshelfIndex].books.isEmpty
    }

    // MARK: - Edit Bar Delegate
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapSelectAll _: UIButton) {
        if allRowsSelected { tableView.deselectAllRows() }
        else { tableView.selectAllRows() }
        
        updateEditBarButtons()
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapMove _: UIButton) {
        isMovingBooks = true
        presentBookshelfOptionsViewController()
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapAdd _: UIButton) {
        isMovingBooks = false
        presentBookshelfOptionsViewController()
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapDelete _: UIButton) {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows!
        let alert = UIAlertController(title: "Delete \(selectedIndexPaths.count) Books",
                                      message: "Are you sure you want to proceed?",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            self.deleteBooksAt(indexPaths: selectedIndexPaths)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Bookshelf Options Delegate
extension BookshelfDetailsViewController: BookshelfOptionsViewControllerDelegate {
    func bookshelfOptionsViewController(_ controller: BookshelfOptionsViewController, didSelectBookshelfAt index: Int) {
        controller.dismiss(animated: true, completion: nil)
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows!
        let bookshelf = storageManager.bookshelves[bookshelfIndex]
        
        // Add books to chosen bookshelf
        for indexPath in selectedIndexPaths {
            let book = bookshelf.books[indexPath.row].with(dateAddedToShelf: Date())
            storageManager.bookshelves[index].addBook(book: book)
        }
        
        // Remove books at current bookshelf if user is moving them
        if isMovingBooks { deleteBooksAt(indexPaths: selectedIndexPaths) }
    }
}
