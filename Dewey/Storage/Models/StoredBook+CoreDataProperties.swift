//
//  StoredBook+CoreDataProperties.swift
//  
//
//  Created by Jessica Huynh on 2020-05-05.
//
//

import Foundation
import CoreData


extension StoredBook {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<StoredBook> {
        return NSFetchRequest<StoredBook>(entityName: "StoredBook")
    }

    @NSManaged public var id: Int32
    @NSManaged public var url: String
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var bookDescription: String
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var publicationDate: String
    @NSManaged public var averageUserRating: Double
    @NSManaged public var userRatingCount: Int32
    @NSManaged public var dateAddedToShelf: Date
    @NSManaged public var dominantColour: String?
    @NSManaged public var bookshelf: Bookshelf

}
