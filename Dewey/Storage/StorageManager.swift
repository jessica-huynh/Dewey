//
//  StorageManager.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    static let instance = StorageManager()
    private(set) var bookshelves: [Bookshelf] = []
    private var bookshelvesForId: [Int32: [Bookshelf]] = [:]
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
    private init() {
        let applicationDocumentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)[0]
        print(applicationDocumentsDirectory)
        loadBookshelves()
    }
    
    // MARK: - Core Data Saving support
    private func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // TODO: Display error message
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Helpers
    private func loadBookshelves() {
        let bookshelvesFetchRequest = Bookshelf.createFetchRequest()
        bookshelvesFetchRequest.entity = Bookshelf.entity()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        bookshelvesFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            bookshelves = try managedObjectContext.fetch(bookshelvesFetchRequest)
            for bookshelf in bookshelves {
                var storedBooks = bookshelf.storedBooks?.allObjects as! [StoredBook]
                storedBooks.sort(by: { $0.dateAddedToShelf > $1.dateAddedToShelf })
                for book in storedBooks {
                    bookshelf.books.append(Book(id: book.id, url: book.url, title: book.title, author: book.author, description: book.bookDescription, artworkUrl100: book.artworkUrl100, publicationDate: book.publicationDate, averageUserRating: book.averageUserRating, userRatingCount: book.userRatingCount, dateAddedToShelf: book.dateAddedToShelf, dominantColour: book.dominantColour == nil ? nil : Colour(hex: book.dominantColour!)))
                    
                    let oldValue = bookshelvesForId[book.id] ?? []
                    bookshelvesForId.updateValue(oldValue + [bookshelf], forKey: book.id)
                }
            }
        } catch {
            print("Fetch request failed: \(error)")
        }
    }
    
    private func updateBookshelfIndexes() {
        for i in 0..<bookshelves.count {
            bookshelves[i].setValue(i, forKey: "index")
        }
        saveContext()
    }
    
    private func deleteStoredBook(book: Book, from bookshelf: Bookshelf? = nil) {
        let bookFetchRequest = StoredBook.createFetchRequest()
        bookFetchRequest.entity = StoredBook.entity()
        if let bookshelf = bookshelf {
            bookFetchRequest.predicate = NSPredicate(format: "id == %i AND bookshelf == %@", book.id, bookshelf)
        } else {
            bookFetchRequest.predicate = NSPredicate(format: "id == %i", book.id)
        }
        
        do {
            let storedBooks = try managedObjectContext.fetch(bookFetchRequest)
            for storedBook in storedBooks {
                managedObjectContext.delete(storedBook)
            }
            saveContext()
        } catch {
            print("Fetch request failed: \(error)")
        }
    }
    
    // MARK: - Modify Bookshelves
    func addBookshelf(with name: String, books: [Book] = []) {
        let bookshelf = Bookshelf(context: managedObjectContext)
        bookshelf.name = name
        bookshelf.index = Int32(bookshelves.count)
        saveContext()
        
        bookshelves.append(bookshelf)
        
        for book in books {
            addBook(book: book, to: bookshelf)
        }
    }
    
    func removeBookshelf(at index: Int) {
        let removedBookshelf = bookshelves.remove(at: index)
        managedObjectContext.delete(removedBookshelf)
        saveContext()
        updateBookshelfIndexes()
        
        for book in removedBookshelf.books {
            updateBookshelves(for: book.id, without: removedBookshelf)
        }
    }
    
    func removeAllBookshelves() {
        bookshelves = []
        bookshelvesForId = [:]
        
        let fetchRequest = Bookshelf.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext.execute(deleteRequest)
        } catch {
            print("Failed to remove all bookshelves: \(error)")
        }
    }
    
    func moveBookshelf(at sourceIndex: Int, to destinationIndex: Int) {
        let movedBookshelf = bookshelves.remove(at: sourceIndex)
        bookshelves.insert(movedBookshelf, at: destinationIndex)
        
        updateBookshelfIndexes()
    }
    
    func updateBookshelf(bookshelf: Bookshelf, name: String) {
        bookshelf.setValue(name, forKey: "name")
        saveContext()
    }
    
    // MARK: - Modify Books
    func addBook(book: Book, to bookshelf: Bookshelf) {
        let today = Date()
        if bookshelf.addBook(book: book.with(dateAddedToShelf: today)) {
            let oldValue = bookshelvesForId[book.id] ?? []
            bookshelvesForId.updateValue(oldValue + [bookshelf], forKey: book.id)
            
            let storedBook = StoredBook(context: managedObjectContext)
            storedBook.id = book.id
            storedBook.url = book.url
            storedBook.title = book.title
            storedBook.author = book.author
            storedBook.bookDescription = book.description
            storedBook.artworkUrl100 = book.artworkUrl100
            storedBook.publicationDate = book.publicationDate
            storedBook.averageUserRating = book.averageUserRating ?? 0
            storedBook.userRatingCount = book.userRatingCount ?? 0
            storedBook.dateAddedToShelf = today
            storedBook.dominantColour = book.dominantColour?.hex
            
            bookshelf.addToStoredBooks(storedBook)
            saveContext()
        }
    }
    
    func removeBook(book: Book, from bookshelf: Bookshelf) {
        bookshelf.removeBook(book: book)
        updateBookshelves(for: book.id, without: bookshelf)
        deleteStoredBook(book: book, from: bookshelf)
    }
    
    func removeBook(at index: Int, from bookshelf: Bookshelf) {
        let removedBook = bookshelf.removeBook(at: index)
        updateBookshelves(for: removedBook.id, without: bookshelf)
        deleteStoredBook(book: removedBook, from: bookshelf)
    }
    
    func removeBookEverywhere(book: Book) {
        let effectedBookshelves = bookshelves.filter {
            bookshelvesForId[book.id]!.contains($0)
        }
        
        for bookshelf in effectedBookshelves {
            bookshelf.removeBook(book: book)
        }
        bookshelvesForId.removeValue(forKey: book.id)
        deleteStoredBook(book: book)
    }
    
    func removeAllBooks(from bookshelf: Bookshelf) {
        let storedBooks = bookshelf.storedBooks!.allObjects as! [StoredBook]
        for storedBook in storedBooks {
            updateBookshelves(for: storedBook.id, without: bookshelf)
            managedObjectContext.delete(storedBook)
        }
        bookshelf.removeAllBooks()
        saveContext()
    }

    // MARK: - Misc Helpers
    private func updateBookshelves(for id: Int32, without bookshelf: Bookshelf) {
        var effectedBookshelves = bookshelvesForId[id]!
        
        for i in 0..<effectedBookshelves.count {
            if effectedBookshelves[i] == bookshelf {
                effectedBookshelves.remove(at: i)
                break
            }
        }
        if effectedBookshelves.isEmpty {
            bookshelvesForId.removeValue(forKey: id)
        } else {
            bookshelvesForId.updateValue(bookshelves, forKey: id)
        }
    }
    
    func bookIsInAShelf(book: Book) -> Bool {
        return bookshelvesForId[book.id] != nil
    }
    
    func numberOfBookshelves(with book: Book) -> Int {
        return bookshelvesForId[book.id]?.count ?? 0
    }
    
    func getDominantColour(for book: Book) -> Colour? {
        guard let bookshelf = bookshelvesForId[book.id]?.first else { return nil }
        let book = bookshelf.books.first(where: { $0.id == book.id })!
        return book.dominantColour
    }
}
