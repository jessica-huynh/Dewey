//
//  BookshelfSectionHeaderView.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-01.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

@objc(BookshelfSectionHeaderView)
class BookshelfSectionHeaderView: UITableViewHeaderFooterView {
    var delegate: BookshelfSectionHeaderViewDelegate?
    var bookshelf: Bookshelf!
    
    @IBOutlet weak var bookshelfName: UILabel!
    
    @IBAction func seeAllTapped(_ sender: UIButton) {
        delegate?.bookshelfSectionHeaderView(self, didTapSeeAll: sender)
    }
}

protocol BookshelfSectionHeaderViewDelegate: class {
    func bookshelfSectionHeaderView(_ bookshelfSectionHeaderView: BookshelfSectionHeaderView, didTapSeeAll button: UIButton)
}
