//
//  Bookshelf.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-05.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import CoreData

@objc(Bookshelf)
public class Bookshelf: NSManagedObject {
    /// The books in the bookshelf, by default, sorted by most recently added.
    var books: [Book] = []
    
    @NSManaged public var name: String
    @NSManaged public var index: Int32
    @NSManaged public var storedBooks: NSSet?
    
    func contains(book: Book) -> Bool {
        return books.contains(where: { $0 == book })
    }
    
    /// Add `book` to the front of `books`
    func addBook(book: Book) {
        books = [book] + books // Maintain order by most recently added
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
    
    /// Updates its `book` property using`storedBooks`.
    func syncBooksWithStorage() {
        var books = self.storedBooks?.allObjects as! [Book]
        books.sort(by: { $0.dateAddedToShelf > $1.dateAddedToShelf })
        self.books = books
    }
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Bookshelf> {
        return NSFetchRequest<Bookshelf>(entityName: "Bookshelf")
    }
    
    // MARK: - Accessors for storedBooks
    @objc(addStoredBooksObject:)
    @NSManaged public func addToStoredBooks(_ value: Book)

    @objc(addStoredBooks:)
    @NSManaged public func addToStoredBooks(_ values: NSSet)
}
