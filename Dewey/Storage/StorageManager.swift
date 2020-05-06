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
    
    lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
    private init() {
        let applicationDocumentsDirectory =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)[0]
        print(applicationDocumentsDirectory)
        loadBookshelvesFromStorage()
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
    private func loadBookshelvesFromStorage() {
        let bookshelvesFetchRequest = Bookshelf.createFetchRequest()
        bookshelvesFetchRequest.entity = Bookshelf.entity()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        bookshelvesFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            bookshelves = try managedObjectContext.fetch(bookshelvesFetchRequest)
            for bookshelf in bookshelves {
                var books = bookshelf.storedBooks?.allObjects as! [Book]
                books.sort(by: { $0.dateAddedToShelf > $1.dateAddedToShelf })
                bookshelf.books = books
                
                for book in books {
                    updateBookshelves(for: book.id, with: bookshelf)
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
        // It is not guaranteed that the passed in `book` is an existing book in
        // storage (e.g. when looking at a book from the search results page).
        // Therefore, we need to fetch the correct stored book first.
        let bookFetchRequest = Book.createFetchRequest()
        bookFetchRequest.entity = Book.entity()
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
        if bookshelf.contains(book: book) { return }
        let storedBook = Book(context: managedObjectContext)
        storedBook.id = book.id
        storedBook.url = book.url
        storedBook.title = book.title
        storedBook.author = book.author
        storedBook.bookDescription = book.bookDescription
        storedBook.artworkUrl100 = book.artworkUrl100
        storedBook.publicationDate = book.publicationDate
        storedBook.rating = book.averageUserRating ?? 0
        storedBook.ratingCount = book.userRatingCount ?? 0
        storedBook.dateAddedToShelf = Date()
        storedBook.dominantColour = book.dominantColour
        
        bookshelf.addBook(book: storedBook)
        bookshelf.addToStoredBooks(storedBook)
        saveContext()
        updateBookshelves(for: book.id, with: bookshelf)
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
        let storedBooks = bookshelf.storedBooks!.allObjects as! [Book]
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
    
    private func updateBookshelves(for id: Int32, with bookshelf: Bookshelf) {
        let oldValue = bookshelvesForId[id] ?? []
        bookshelvesForId.updateValue(oldValue + [bookshelf], forKey: id)
    }
    
    func bookIsInAShelf(book: Book) -> Bool {
        return bookshelvesForId[book.id] != nil
    }
    
    func numberOfBookshelves(with book: Book) -> Int {
        return bookshelvesForId[book.id]?.count ?? 0
    }
    
    func getDominantColour(for book: Book) -> String? {
        guard let bookshelf = bookshelvesForId[book.id]?.first else { return nil }
        let book = bookshelf.books.first(where: { $0.id == book.id })!
        return book.dominantColour
    }
}
