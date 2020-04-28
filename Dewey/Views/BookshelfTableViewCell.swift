//
//  BookshelfTableViewCell.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookshelfTableViewCell: UITableViewCell, UICollectionViewDataSource {
    var bookshelf: Bookshelf!
    
    @IBOutlet weak var bookCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookCollectionView.dataSource = self
        bookCollectionView.showsHorizontalScrollIndicator = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookshelf.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let book = bookshelf.books[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionCell", for: indexPath) as! BookCollectionViewCell
        cell.book = book
        cell.configure()
        return cell
    }
}
