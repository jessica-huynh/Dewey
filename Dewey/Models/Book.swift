//
//  Book.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Book {
    let isbn, title, author, description, cover: String
    var dateAddedToShelf: Date?
    
    func with(dateAddedToShelf: Date) -> Book {
        return Book(isbn: self.isbn,
                    title: self.title,
                    author: self.author,
                    description: self.description,
                    cover: self.cover,
                    dateAddedToShelf: dateAddedToShelf)
    }
}
