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
    private var bookshelvesForIsbn: [Int: [Int]] = [:]
    
    private init() {
    }
    
    func addBookshelf(with name: String, books: [Book] = []) {
        let bookshelf = Bookshelf(id: bookshelfID, name: name)
        bookshelfID = bookshelfID + 1
        bookshelves.append(bookshelf)
        
        for book in books {
            addBook(book: book, to: bookshelf)
        }
    }
    
    func removeBookshelf(at index: Int) {
        let removedBookshelf = bookshelves.remove(at: index)
        for book in removedBookshelf.books {
            updateBookshelves(for: book.id, without: removedBookshelf)
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
        if bookshelf.addBook(book: book.with(dateAddedToShelf: Date())) {
            let oldValue = bookshelvesForIsbn[book.id] ?? []
            bookshelvesForIsbn.updateValue(oldValue + [bookshelf.id], forKey: book.id)
        }
    }
    
    func removeBook(book: Book, from bookshelf: Bookshelf) {
        bookshelf.removeBook(book: book)
        updateBookshelves(for: book.id, without: bookshelf)
    }
    
    func removeBook(at index: Int, from bookshelf: Bookshelf) {
        let removedBook = bookshelf.removeBook(at: index)
        updateBookshelves(for: removedBook.id, without: bookshelf)
    }
    
    func removeBookEverywhere(book: Book) {
        let effectedBookshelves = bookshelves.filter {
            bookshelvesForIsbn[book.id]!.contains($0.id)
        }
        
        for bookshelf in effectedBookshelves {
            bookshelf.removeBook(book: book)
        }
        bookshelvesForIsbn.removeValue(forKey: book.id)
    }
    
    func removeAllBooks(from bookshelf: Bookshelf) {
        for book in bookshelf.books {
            updateBookshelves(for: book.id, without: bookshelf)
        }
        bookshelf.removeAllBooks()
    }
    
    func updateBookshelves(for id: Int, without bookshelf: Bookshelf) {
        var bookshelfIds = bookshelvesForIsbn[id]!
        
        for i in 0..<bookshelfIds.count {
            if bookshelfIds[i] == bookshelf.id {
                bookshelfIds.remove(at: i)
                break
            }
        }
        if bookshelfIds.isEmpty {
            bookshelvesForIsbn.removeValue(forKey: id)
        } else {
            bookshelvesForIsbn.updateValue(bookshelfIds, forKey: id)
        }
    }
    
    func bookIsInAShelf(book: Book) -> Bool {
        return bookshelvesForIsbn[book.id] != nil
    }
    
    func numberOfBookshelves(with book: Book) -> Int {
        return bookshelvesForIsbn[book.id]?.count ?? 0
    }
}
