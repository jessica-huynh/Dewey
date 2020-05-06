//
//  Bookshelf+CoreDataProperties.swift
//  
//
//  Created by Jessica Huynh on 2020-05-05.
//
//

import Foundation
import CoreData


extension Bookshelf {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Bookshelf> {
        return NSFetchRequest<Bookshelf>(entityName: "Bookshelf")
    }

    @NSManaged public var name: String
    @NSManaged public var index: Int32
    @NSManaged public var storedBooks: NSSet?
}

// MARK: Generated accessors for books
extension Bookshelf {
    @objc(addStoredBooksObject:)
    @NSManaged public func addToStoredBooks(_ value: StoredBook)

    @objc(removeStoredBooksObject:)
    @NSManaged public func removeFromStoredBooks(_ value: StoredBook)

    @objc(addStoredBooks:)
    @NSManaged public func addToStoredBooks(_ values: NSSet)

    @objc(removeStoredBooks:)
    @NSManaged public func removeFromStoredBooks(_ values: NSSet)
}
