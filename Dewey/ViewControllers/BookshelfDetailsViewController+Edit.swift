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
        updateEditBarButtons()
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
    
    func presentBookshelfOptionsViewController(with title: String) {
        let bookshelfOptionsViewController = BookshelfOptionsViewController()
        bookshelfOptionsViewController.delegate = self
        bookshelfOptionsViewController.bookshelfToDisable = bookshelf
        bookshelfOptionsViewController.title = title
        
        present(UINavigationController.custom(with: bookshelfOptionsViewController), animated: true, completion: nil)
    }
    
    func updateEditBarButtons() {
        let numberOfSelectedRows = tableView.indexPathsForSelectedRows?.count
        atLeastOneRowSelected = numberOfSelectedRows ?? 0 > 0
        
        let totalBooks = bookshelf.books.count
        allRowsSelected = numberOfSelectedRows == totalBooks
        
        noBooks = bookshelf.books.isEmpty
    }

    // MARK: - Edit Bar Delegate
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapSelectAll _: UIButton) {
        if allRowsSelected { tableView.deselectAllRows() }
        else { tableView.selectAllRows() }
        
        updateEditBarButtons()
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapMove _: UIButton) {
        presentBookshelfOptionsViewController(with: "Move To A Bookshelf")
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapAdd _: UIButton) {
        presentBookshelfOptionsViewController(with: "Add To A Bookshelf")
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapDelete _: UIButton) {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows!
        let alert = UIAlertController(title: "Delete \(selectedIndexPaths.count) Books",
                                      message: "Are you sure you want to proceed?",
                                      preferredStyle: .alert)
        alert.view.tintColor = .darkGray
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
        
        // Add books to chosen bookshelf
        for indexPath in selectedIndexPaths {
            let book = bookshelf.books[indexPath.row]
            let destinationBookshelf = storageManager.bookshelves[index]
            storageManager.addBook(book: book, to: destinationBookshelf)
        }
        
        // Remove books at current bookshelf if user is moving them
        if editBar.currentAction == .move { deleteBooksAt(indexPaths: selectedIndexPaths) }
        ConfirmationHudView.present(inView: self.navigationController!.view, animated: true)
    }
}
