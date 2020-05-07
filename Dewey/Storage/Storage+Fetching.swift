//
//  Storage+Fetching.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-07.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import BackgroundTasks

extension StorageManager {
    func fetchBookUpdates(_ task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let updateOperation = {
            let bookFetchRequest = Book.createFetchRequest()
            bookFetchRequest.entity = Book.entity()
            do {
                let books = try self.managedObjectContext.fetch(bookFetchRequest)
                let dispatch = DispatchGroup()
                
                for book in books {
                    dispatch.enter()
                    iTunesSearchAPI.request(for: .lookup(id: book.id)) {
                        response in
                        if let updatedBook = try SearchResponse(data: response.data).results.first {
                            if book.coverLarge != updatedBook.coverLarge {
                                book.setValue(updatedBook.artworkUrl100, forKey: "artworkUrl100")
                                book.setValue(nil, forKey: "dominantColour")
                            }
                            book.setValue(updatedBook.bookDescription, forKey: "bookDescription")
                            book.setValue(updatedBook.rating, forKey: "rating")
                            book.setValue(updatedBook.ratingCount, forKey: "ratingCount")
                        }
                        dispatch.leave()
                    }
                }
                
                dispatch.notify(queue: .main) {
                    self.saveContext()
                    NotificationCenter.default.post(name: .updatedBookshelves, object: nil)
                }
            } catch {
                print("Fetch request failed: \(error)")
            }
        }
        queue.addOperation(updateOperation)

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
            let request = BGAppRefreshTaskRequest(identifier: "fetchBookUpdates")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
}
