//
//  UITableView+SelectAll.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-30.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func selectAllRows() {
        for section in 0..<numberOfSections {
            for row in 0..<numberOfRows(inSection: section) {
                selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
            }
        }
    }
    
    func deselectAllRows() {
        for section in 0..<numberOfSections {
            for row in 0..<numberOfRows(inSection: section) {
                deselectRow(at: IndexPath(row: row, section: section), animated: false)
            }
        }
    }
}
