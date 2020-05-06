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
    @NSManaged public var id: Int32
    @NSManaged public var url, title, author, bookDescription: String
    @NSManaged public var artworkUrl100: String?
    /// A string representing the publication date in ISO 8601 format (i.e. YYYY-MM-DD)
    @NSManaged public var publicationDate: String
    
    // Do not access the following 2 optionals directly. Instead, use the NSManaged
    // variables above to get the rating information.
    var averageUserRating: Double?
    var userRatingCount: Int32?
    
    // Variables unrelated to iTunes API response:
    @NSManaged public var rating: Double
    @NSManaged public var ratingCount: Int32
    @NSManaged public var dateAddedToShelf: Date
    @NSManaged public var dominantColour: String?
    
    lazy var coverSmall: String = Book.processCoverUrl(url: artworkUrl100, size: 200)
    lazy var coverLarge: String = Book.processCoverUrl(url: artworkUrl100, size: 900)
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
        let container = encoder.container(keyedBy: CodingKeys.self)
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
    
    static func processCoverUrl(url: String?, size: Int) -> String {
        guard let url = url else { return "" }
        let endIndex = url.index(url.endIndex, offsetBy: -13)
        return url[...endIndex] + "\(size)x\(size).jpg"
    }
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
}
