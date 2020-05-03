//
//  Book.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Book: Codable, Equatable {
    let id: Int
    let url, title, author, description: String
    let artworkUrl100: String?
    /// A string representing the publication date in ISO 8601 format (i.e. YYYY-MM-DD)
    let publicationDate: String
    let genres: [String]
    let averageUserRating: Double?
    let userRatingCount: Int?
    
    var coverSmall: String { return Book.processCoverUrl(url: artworkUrl100, size: 200) }
    var coverLarge: String { return Book.processCoverUrl(url: artworkUrl100, size: 900) }
    var publicationYear: String { return String(publicationDate.prefix(4)) }
    var dateAddedToShelf: Date?

    enum CodingKeys: String, CodingKey {
        case genres, description, averageUserRating, userRatingCount, artworkUrl100
        case url = "trackViewUrl"
        case id = "trackId"
        case title = "trackName"
        case publicationDate = "releaseDate"
        case author = "artistName"
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
    init(data: Data) throws {
        self = try JSONDecoder().decode(Book.self, from: data)
    }
    
    func with(dateAddedToShelf: Date) -> Book {
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
                    dateAddedToShelf: dateAddedToShelf)
        }
}
