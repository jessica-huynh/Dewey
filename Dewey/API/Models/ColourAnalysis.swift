//
//  ColourAnalysis.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-04.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct ColourAnalysis: Codable {
    let dominantColour: Colour
    let accentColours, otherColours: [Colour]
    
    enum CodingKeys: String, CodingKey {
        case dominantColour = "dominant"
        case accentColours = "accent"
        case otherColours = "other"
    }
}

extension ColourAnalysis {
    init(data: Data) throws {
        self = try JSONDecoder().decode(ColourAnalysis.self, from: data)
    }
}
