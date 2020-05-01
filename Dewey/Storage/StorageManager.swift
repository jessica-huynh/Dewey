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
    
    private var bookshelfID: Int = 0
    private(set) var bookshelves: [Bookshelf] = []
    private var bookshelvesForIsbn: [String: [Int]] = [:]
    
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
        
        var favs: [Book] = []
        favs.append(book3.with(dateAddedToShelf: Date()))
        favs.append(book4.with(dateAddedToShelf: Date()))
        
        addBookshelf(with: "Bestsellers", books: bestsellers)
        addBookshelf(with: "Favourites", books: favs)
        addBookshelf(with: "Want To Read")
    }
    
    func addBookshelf(with name: String, books: [Book] = []) {
        let bookshelf = Bookshelf(id: bookshelfID, name: name, books: books)
        bookshelves.append(bookshelf)
        bookshelfID = bookshelfID + 1
        
        for book in books {
            addBook(book: book, to: bookshelf)
            let oldValue: [Int] = bookshelvesForIsbn[book.isbn] ?? []
            bookshelvesForIsbn.updateValue([bookshelf.id] + oldValue, forKey: book.isbn)
        }
    }
    
    func removeBookshelf(at index: Int) {
        let removedBookshelf = bookshelves.remove(at: index)
        for book in removedBookshelf.books {
            updateBookshelves(for: book.isbn, without: removedBookshelf)
        }
    }
    
    func removeAllBookshelves() {
        bookshelves = []
        bookshelvesForIsbn = [:]
    }
    
    func moveBookshelf(at sourceIndex: Int, to destinationIndex: Int) {
        let movedBookshelf = bookshelves.remove(at: sourceIndex)
        bookshelves.insert(movedBookshelf, at: destinationIndex)
    }
    
    func addBook(book: Book, to bookshelf: Bookshelf) {
        if bookshelf.addBook(book: book) {
            let oldValue = bookshelvesForIsbn[book.isbn]!
            bookshelvesForIsbn.updateValue(oldValue + [bookshelf.id], forKey: book.isbn)
        }
    }
    
    func removeBook(at index: Int, from bookshelf: Bookshelf) {
        let removedBook = bookshelf.removeBook(at: index)
        updateBookshelves(for: removedBook.isbn, without: bookshelf)
    }
    
    func removeAllBooks(from bookshelf: Bookshelf) {
        for book in bookshelf.books {
            updateBookshelves(for: book.isbn, without: bookshelf)
        }
        bookshelf.removeAllBooks()
    }
    
    func updateBookshelves(for isbn: String, without bookshelf: Bookshelf) {
        var bookshelfIds = bookshelvesForIsbn[isbn]!
        
        for i in 0..<bookshelfIds.count {
            if bookshelfIds[i] == bookshelf.id {
                bookshelfIds.remove(at: i)
                break
            }
        }
        if bookshelfIds.isEmpty {
            bookshelvesForIsbn.removeValue(forKey: isbn)
        } else {
            bookshelvesForIsbn.updateValue(bookshelfIds, forKey: isbn)
        }
    }
}
