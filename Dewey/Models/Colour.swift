//
//  Colour.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-04.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Colour: Codable {
    let hex: String
}

extension Colour {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Colour.self, from: data)
    }
}
