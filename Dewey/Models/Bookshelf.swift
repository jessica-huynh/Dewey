//
//  Bookshelf.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Bookshelf {
    let id: Int
    var name: String
    var books: [Book] = []
    
    init(id: Int, name: String, books: [Book] = []) {
        self.id = id
        self.name = name
        self.books = books
    }
    
    func contains(book: Book) -> Bool {
        return books.contains(where: { $0.isbn == book.isbn })
    }
    
    func addBook(book: Book) -> Bool {
        if self.contains(book: book) { return false }
        books = [book] + books // Maintain order by most recently added
        return true
    }
    
    func removeBook(at index: Int) -> Book {
        return books.remove(at: index)
    }
    
    func removeAllBooks() {
        books = []
    }
}
