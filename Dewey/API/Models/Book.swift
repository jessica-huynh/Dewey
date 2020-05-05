//
//  Book.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Book: Codable, Equatable {
    let id: Int
    let url, title, author, description: String
    let artworkUrl100: String?
    /// A string representing the publication date in ISO 8601 format (i.e. YYYY-MM-DD)
    let publicationDate: String
    let genres: [String]
    let averageUserRating: Double?
    let userRatingCount: Int?
    
    lazy var coverSmall: String = Book.processCoverUrl(url: artworkUrl100, size: 200)
    lazy var coverLarge: String = Book.processCoverUrl(url: artworkUrl100, size: 900)
    var publicationYear: String { return String(publicationDate.prefix(4)) }
    var dateAddedToShelf: Date?
    var dominantColour: Colour?

    enum CodingKeys: String, CodingKey {
        case genres, description, averageUserRating, userRatingCount, artworkUrl100
        case url = "trackViewUrl"
        case id = "trackId"
        case title = "trackName"
        case publicationDate = "releaseDate"
        case author = "artistName"
    }
    
    init(id: Int,
         url: String,
         title: String,
         author: String,
         description: String,
         artworkUrl100: String?,
         publicationDate: String,
         genres: [String],
         averageUserRating: Double?,
         userRatingCount: Int?,
         dateAddedToShelf: Date?,
         dominantColour: Colour?) {
        self.id = id
        self.url = url
        self.title = title
        self.author = author
        self.description = description
        self.artworkUrl100 = artworkUrl100
        self.publicationDate = publicationDate
        self.genres = genres
        self.averageUserRating = averageUserRating
        self.userRatingCount = userRatingCount
        self.dateAddedToShelf = dateAddedToShelf
        self.dominantColour = dominantColour
    }
    
    static func processCoverUrl(url: String?, size: Int) -> String {
        guard let url = url else { return "" }
        let endIndex = url.index(url.endIndex, offsetBy: -13)
        return url[...endIndex] + "\(size)x\(size).jpg"
    }
    
    static func ==(lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Book {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Book.self, from: data)
        self.init(id: me.id,
                  url: me.url,
                  title: me.title,
                  author: me.author,
                  description: me.description,
                  artworkUrl100: me.artworkUrl100,
                  publicationDate: me.publicationDate,
                  genres: me.genres,
                  averageUserRating: me.averageUserRating,
                  userRatingCount: me.userRatingCount,
                  dateAddedToShelf: me.dateAddedToShelf,
                  dominantColour: me.dominantColour)
    }
    
    func with(dateAddedToShelf: Date? = nil) -> Book {
        return Book(id: self.id,
                    url: self.url,
                    title: self.title,
                    author: self.author,
                    description: self.description,
                    artworkUrl100: self.artworkUrl100,
                    publicationDate: self.publicationDate,
                    genres: self.genres,
                    averageUserRating: self.averageUserRating,
                    userRatingCount: self.userRatingCount,
                    dateAddedToShelf: dateAddedToShelf,
                    dominantColour: self.dominantColour)
        }
}
