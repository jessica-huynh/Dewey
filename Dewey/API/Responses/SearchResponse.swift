//
//  SearchResponse.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-02.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    let resultCount: Int
    let results: [Book]
}

extension SearchResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(SearchResponse.self, from: data)
    }
}
