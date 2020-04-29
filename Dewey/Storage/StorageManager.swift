//
//  StorageManager.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class StorageManager {
    static let instance = StorageManager()
    
    var bookshelves: [Bookshelf] = []
    
    private init() {
        let book1 = Book(isbn: "0735219095", title: "Where the Crawdads Sing", author: "Delia Owens", description: "In a quiet town on the North Carolina coast in 1969, a young woman who survived alone in the marsh becomes a murder suspect.", cover: "https://s1.nyt.com/du/books/images/9780735219090.jpg")
        let book2 = Book(isbn: "0525539522", title: "Masked Prey", author: "John Sandford", description: "The 30th book in the Prey series. Washington politicians ask Lucas Davenport to look into someone who is targeting their children.", cover: "https://s1.nyt.com/du/books/images/9780525539520.jpg")
        let book3 = Book(isbn: "1250209765", title: "American Dirt", author: "Jeanine Cummins", description: "A bookseller flees Mexico for the United States with her son while pursued by the head of a drug cartel.", cover: "https://s1.nyt.com/du/books/images/9781250209764.jpg")
        let book4 = Book(isbn: "1250301696", title: "The Silent Patient", author: "Alex Michaelides", description: "Theo Faber looks into the mystery of a famous painter who stops speaking after shooting her husband.", cover: "https://s1.nyt.com/du/books/images/9781250301697.jpg")
        
        var bestsellers: [Book] = []
        bestsellers.append(book1.with(dateAddedToShelf: Date()))
        bestsellers.append(book2.with(dateAddedToShelf: Date()))
        bestsellers.append(book3.with(dateAddedToShelf: Date()))
        bestsellers.append(book4.with(dateAddedToShelf: Date()))
        
        let bestsellersShelf = Bookshelf(name: "Bestsellers", books: bestsellers)
        bookshelves.append(bestsellersShelf)
        
        var favs: [Book] = []
        favs.append(book3.with(dateAddedToShelf: Date()))
        favs.append(book4.with(dateAddedToShelf: Date()))
        
        bookshelves.append(Bookshelf(name: "Want To Read"))
        bookshelves.append(Bookshelf(name: "Favourites", books: favs))
    }
}
