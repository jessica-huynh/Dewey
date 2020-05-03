//
//  BookCollectionViewCell.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit
import Kingfisher

class BookCollectionViewCell: UICollectionViewCell {
    var book: Book!
    var originatingBookshelf: Bookshelf!
    
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    
    func configure() {
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
        bookAuthor.text = book.author
    }
}
