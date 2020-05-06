//
//  Bookshelf+CoreDataClass.swift
//  
//
//  Created by Jessica Huynh on 2020-05-05.
//
//

import Foundation
import CoreData

@objc(Bookshelf)
public class Bookshelf: NSManagedObject {
    var books: [Book] = []
    
    func contains(book: Book) -> Bool {
        return books.contains(where: { $0 == book })
    }
    
    func addBook(book: Book) -> Bool {
        if self.contains(book: book) { return false }
        books = [book] + books // Maintain order by most recently added
        return true
    }
    
    func removeBook(book: Book) {
        let index = books.firstIndex(where: { $0 == book })!
        books.remove(at: index)
    }
    
    func removeBook(at index: Int) -> Book {
        return books.remove(at: index)
    }
    
    func removeAllBooks() {
        books = []
    }
}
