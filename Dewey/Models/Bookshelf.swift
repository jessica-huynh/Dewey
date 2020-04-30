//
//  Bookshelf.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Bookshelf {
    var name: String
    var books: [Book] = []
    
    init(name: String, books: [Book] = []) {
        self.name = name
        self.books = books
    }
    
    func contains(book: Book) -> Bool {
        return books.contains(where: { $0.isbn == book.isbn })
    }
    
    func addBook(book: Book) {
        if self.contains(book: book) { return }
        books = [book] + books // Maintain order by most recently added
    }
    
    func removeBook(at index: Int) {
        books.remove(at: index)
    }
    
    func removeAllBooks() {
        books = []
    }
}
