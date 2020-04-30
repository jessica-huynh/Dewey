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

    // MARK: - Edit Bar Delegate
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapSelectAll _: UIButton) {
        if allRowsSelected { tableView.deselectAllRows() }
        else { tableView.selectAllRows() }
        
        updateRowSelectionStatus()
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapMove _: UIButton) {
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapAdd _: UIButton) {
    }
    
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapDelete _: UIButton) {
        var selectedIndexPaths = tableView.indexPathsForSelectedRows!
        let alert = UIAlertController(title: "Delete \(selectedIndexPaths.count) Bookshelves",
                                      message: "Are you sure you want to proceed?",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            selectedIndexPaths.sort(by: { $0.row > $1.row })
            for indexPath in selectedIndexPaths {
                self.storageManager.bookshelves[self.bookshelfIndex].books.remove(at: indexPath.row)
            }
            self.tableView.deleteRows(at: selectedIndexPaths, with: .fade)
            self.updateRowSelectionStatus()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
