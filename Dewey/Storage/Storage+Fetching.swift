//
//  Storage+Fetching.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-07.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit
import BackgroundTasks

extension StorageManager {
    // MARK: Periodic Fetch
    func fetchBookUpdatesIfNeeded() {
        let lastFetchUpdate = UserDefaults.standard.object(forKey: "lastFetchUpdate") as! Date
        let timeDifference = Calendar.current.dateComponents([.hour], from: lastFetchUpdate, to: Date()).hour!

        if timeDifference > 24 && !bookshelvesForId.isEmpty {
            isFetchingUpdates = true
            NotificationCenter.default.post(name: .beganFetchUpdates, object: nil)
            fetchBookUpdates()
        }
    }
    
    func fetchBookUpdates() {
        let dispatch = DispatchGroup()
        let uniqueBookIds: [Int32] = Array(bookshelvesForId.keys)
        for id in uniqueBookIds  {
            let bookFetchRequest = Book.createFetchRequest()
            bookFetchRequest.entity = Book.entity()
            bookFetchRequest.predicate = NSPredicate(format: "id == %i", id)
            
            do {
                dispatch.enter()
                let books = try self.managedObjectContext.fetch(bookFetchRequest)
                
                iTunesSearchAPI.request(for: .lookup(id: id)) {
                    response in
                    
                    if let updatedBook = try SearchResponse(data: response.data).results.first {
                        for book in books {
                            if book.coverLarge != updatedBook.coverLarge {
                                book.setValue(updatedBook.artworkUrl100, forKey: "artworkUrl100")
                                book.setValue(nil, forKey: "dominantColour")
                            }
                            book.setValue(updatedBook.bookDescription, forKey: "bookDescription")
                            book.setValue(updatedBook.rating, forKey: "rating")
                            book.setValue(updatedBook.ratingCount, forKey: "ratingCount")
                        }
                    }
                    dispatch.leave()
                }
                
                dispatch.notify(queue: .main) {
                    self.saveContext()
                    UserDefaults.standard.set(Date(), forKey: "lastFetchUpdate")
                    self.isFetchingUpdates = false
                    self.bookshelves.forEach { $0.syncBooksWithStorage() }
                    NotificationCenter.default.post(name: .updatedBookshelves, object: nil)
                }
            } catch {
                print("Fetch request failed: \(error)")
            }
        }
    }
    
    // MARK: - Background App Refresh
    func startAppRefresh(_ task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation{ self.fetchBookUpdates() }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }

        scheduleAppRefresh()
    }

    func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "startAppRefresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
}

extension Notification.Name {
    static let beganFetchUpdates = Notification.Name("beganFetchUpdates")
}
