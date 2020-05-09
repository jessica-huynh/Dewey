//
//  Book.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import CoreData

@objc(Book)
public class Book: NSManagedObject, Codable {
    /// The book's iTunes id
    @NSManaged public var id: Int32
    @NSManaged public var url, title, author, bookDescription: String
    /// A URL for the book cover with size 100x100.
    @NSManaged public var artworkUrl100: String?
    /// A string representing the publication date in ISO 8601 format (i.e. YYYY-MM-DD)
    @NSManaged public var publicationDate: String
    
    /** The book's average user rating as returned by the API.  **Do not use this property directly. Instead, use** `rating` **to get the book's rating.**
     */
    private var averageUserRating: Double?
    /** The book's rating count as returned by the API.  **Do not use this property directly. Instead, use** `ratingCount` **to get the book's rating.**
    */
    private var userRatingCount: Int32?
    
    // Variables unrelated to iTunes API response:
    @NSManaged public var rating: Double
    @NSManaged public var ratingCount: Int32
    @NSManaged public var dateAddedToShelf: Date
    /// The dominant colour of the book cover.
    @NSManaged public var dominantColour: String?
    /**
    The bookshelf this book belongs to.
     - Note: This value can be empty (but non-nil) if the book does not belong to any bookshelf (e.g. when the user is searching for books).
     */
    @NSManaged public var bookshelf: Bookshelf
    
    var coverSmall: String { return Book.processCoverUrl(url: artworkUrl100, size: 200) }
    var coverLarge: String { return Book.processCoverUrl(url: artworkUrl100, size: 900) }
    var publicationYear: String { return String(publicationDate.prefix(4)) }
    
    enum CodingKeys: String, CodingKey {
        case averageUserRating, userRatingCount, artworkUrl100
        case bookDescription = "description"
        case url = "trackViewUrl"
        case id = "trackId"
        case title = "trackName"
        case publicationDate = "releaseDate"
        case author = "artistName"
    }
    
     // MARK: - Decodable
    required convenience public init(from decoder: Decoder) throws {
        let managedObjectContext = StorageManager.instance.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Book",
                                                in: managedObjectContext)!
        self.init(entity: entity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int32.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        self.author = try container.decode(String.self, forKey: .author)
        self.bookDescription = try container.decode(String.self, forKey: .bookDescription)
        self.artworkUrl100 = try container.decodeIfPresent(String.self, forKey: .artworkUrl100)
        self.publicationDate = try container.decode(String.self, forKey: .publicationDate)
        self.averageUserRating = try container.decodeIfPresent(Double.self, forKey: .averageUserRating)
        self.userRatingCount = try container.decodeIfPresent(Int32.self, forKey: .userRatingCount)
        self.rating = averageUserRating ?? 0
        self.ratingCount = userRatingCount ?? 0
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(author, forKey: .author)
        try container.encode(bookDescription, forKey: .bookDescription)
        try container.encode(artworkUrl100, forKey: .artworkUrl100)
        try container.encode(publicationDate, forKey: .publicationDate)
        try container.encode(averageUserRating, forKey: .averageUserRating)
        try container.encode(userRatingCount, forKey: .userRatingCount)
    }
    
    // MARK: - Equatable
    static func ==(lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Helpers
    static func parse(data: Data) throws -> Book {
        return try JSONDecoder().decode(Book.self, from: data)
    }
    
    /// Returns the book cover URL with a given `size`
    static func processCoverUrl(url: String?, size: Int) -> String {
        guard let url = url else { return "" }
        let endIndex = url.index(url.endIndex, offsetBy: -13)
        return url[...endIndex] + "\(size)x\(size).jpg"
    }
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
}
