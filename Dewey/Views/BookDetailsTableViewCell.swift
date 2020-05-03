//
//  BookDetailsTableViewCell.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-28.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var publicationYear: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    
    func configure(book: Book) {
        let url = URL(string: book.coverSmall)
        bookCover.kf.indicatorType = .activity
        bookCover.kf.setImage(
            with: url,
            placeholder: UIImage(named: "book-cover-placeholder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        
        bookTitle.text = book.title
        author.text = book.author
        bookDescription.text = book.description
    }
}
