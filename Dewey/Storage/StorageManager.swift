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
    var bookshelvesForId: [Int32: [Bookshelf]] = [:]
    var isFetchingUpdates = false
    
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
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Helpers
    func execute<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>, completionHandler: @escaping ([T]) -> Void) {
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            completionHandler(result)
        } catch {
            print("Fetch request failed: \(error)")
        }
    }
    
    private func loadBookshelvesFromStorage() {
        let bookshelvesFetchRequest = Bookshelf.createFetchRequest()
        bookshelvesFetchRequest.entity = Bookshelf.entity()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        bookshelvesFetchRequest.sortDescriptors = [sortDescriptor]
        
        execute(fetchRequest: bookshelvesFetchRequest) {
            [weak self] bookshelves in
            guard let self = self else { return }
            
            self.bookshelves = bookshelves
            for bookshelf in bookshelves {
                bookshelf.syncBooksWithStorage()
                
                let books = bookshelf.storedBooks?.allObjects as! [Book]
                for book in books {
                    self.updateBookshelves(for: book.id, with: bookshelf)
                }
            }
        }
    }
    
    private func updateBookshelfIndexes() {
        for i in 0..<bookshelves.count {
            bookshelves[i].setValue(i, forKey: "index")
        }
        saveContext()
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
        updateBookshelfIndexes()
        
        for book in removedBookshelf.books {
            updateBookshelves(for: book.id, without: removedBookshelf)
        }
        
        managedObjectContext.delete(removedBookshelf)
        saveContext()
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
        storedBook.rating = book.rating
        storedBook.ratingCount = book.ratingCount
        storedBook.dateAddedToShelf = Date()
        storedBook.dominantColour = book.dominantColour
        
        bookshelf.addBook(book: storedBook)
        bookshelf.addToStoredBooks(storedBook)
        saveContext()
        updateBookshelves(for: book.id, with: bookshelf)
    }
    
    func removeBookFromBookshelf(book: Book) {
        let bookshelf = book.bookshelf
        bookshelf.removeBook(book: book)
        updateBookshelves(for: book.id, without: bookshelf)
        managedObjectContext.delete(book)
        saveContext()
    }
    
    func removeBook(at index: Int, from bookshelf: Bookshelf) {
        let removedBook = bookshelf.removeBook(at: index)
        updateBookshelves(for: removedBook.id, without: bookshelf)
        managedObjectContext.delete(removedBook)
        saveContext()
    }
    
    func removeBookEverywhere(book: Book) {
        let effectedBookshelves = bookshelves.filter {
            bookshelvesForId[book.id]!.contains($0)
        }
        
        for bookshelf in effectedBookshelves {
            bookshelf.removeBook(book: book)
        }
        bookshelvesForId.removeValue(forKey: book.id)
        
        let bookFetchRequest = Book.createFetchRequest()
        bookFetchRequest.entity = Book.entity()
        bookFetchRequest.predicate = NSPredicate(format: "id == %i", book.id)
        
        execute(fetchRequest: bookFetchRequest) {
            [weak self] storedBooks in
            guard let self = self else { return }
            
            for storedBook in storedBooks {
                self.managedObjectContext.delete(storedBook)
            }
            self.saveContext()
        }
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
    
    func updateDominantColour(for book: Book, with dominantColour: String) {
        guard let effectedBookshelves = bookshelvesForId[book.id] else { return }
        for bookshelf in effectedBookshelves {
            let storedBook = bookshelf.books.first(where: {$0.id == book.id })
            storedBook!.setValue(dominantColour, forKey: "dominantColour")
        }
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
            bookshelvesForId.updateValue(effectedBookshelves, forKey: id)
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
