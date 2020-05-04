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
    private var bookshelvesForId: [Int: [Int]] = [:]
    
    private init() {
        let description = "\"Turning the envelope over, his hand trembling, Harry saw a purple wax seal bearing a coat of arms; a lion, an eagle, a badger and a snake surrounding a large letter 'H'.\"<br /><br />Harry Potter has never even heard of Hogwarts when the letters start dropping on the doormat at number four, Privet Drive. Addressed in green ink on yellowish parchment with a purple seal, they are swiftly confiscated by his grisly aunt and uncle. Then, on Harry's eleventh birthday, a great beetle-eyed giant of a man called Rubeus Hagrid bursts in with some astonishing news: Harry Potter is a wizard, and he has a place at Hogwarts School of Witchcraft and Wizardry. An incredible adventure is about to begin!"
        let book1 = Book(id: 1, url: "https://books.apple.com/us/book/harry-potter-and-the-sorcerers-stone-enhanced-edition/id1037193578?uo=4", title: "Harry Potter and the Sorcerer's Stone (Enhanced Edition)", author: "J.K. Rowling", description: description, artworkUrl100: "https://is4-ssl.mzstatic.com/image/thumb/Publication3/v4/d2/c0/2f/d2c02f2a-a388-3310-95e2-34ab4d65d0cd/source/100x100bb.jpg", publicationDate: "2015-11-20T08:00:00Z", genres: ["Action & Adventure"], averageUserRating: nil, userRatingCount: nil, dateAddedToShelf: nil)
        
        addBookshelf(with: "Favourites", books: [book1])
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
        bookshelvesForId = [:]
    }
    
    func moveBookshelf(at sourceIndex: Int, to destinationIndex: Int) {
        let movedBookshelf = bookshelves.remove(at: sourceIndex)
        bookshelves.insert(movedBookshelf, at: destinationIndex)
    }
    
    func addBook(book: Book, to bookshelf: Bookshelf) {
        if bookshelf.addBook(book: book.with(dateAddedToShelf: Date())) {
            let oldValue = bookshelvesForId[book.id] ?? []
            bookshelvesForId.updateValue(oldValue + [bookshelf.id], forKey: book.id)
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
            bookshelvesForId[book.id]!.contains($0.id)
        }
        
        for bookshelf in effectedBookshelves {
            bookshelf.removeBook(book: book)
        }
        bookshelvesForId.removeValue(forKey: book.id)
    }
    
    func removeAllBooks(from bookshelf: Bookshelf) {
        for book in bookshelf.books {
            updateBookshelves(for: book.id, without: bookshelf)
        }
        bookshelf.removeAllBooks()
    }
    
    func updateBookshelves(for id: Int, without bookshelf: Bookshelf) {
        var bookshelfIds = bookshelvesForId[id]!
        
        for i in 0..<bookshelfIds.count {
            if bookshelfIds[i] == bookshelf.id {
                bookshelfIds.remove(at: i)
                break
            }
        }
        if bookshelfIds.isEmpty {
            bookshelvesForId.removeValue(forKey: id)
        } else {
            bookshelvesForId.updateValue(bookshelfIds, forKey: id)
        }
    }
    
    func bookIsInAShelf(book: Book) -> Bool {
        return bookshelvesForId[book.id] != nil
    }
    
    func numberOfBookshelves(with book: Book) -> Int {
        return bookshelvesForId[book.id]?.count ?? 0
    }
}
