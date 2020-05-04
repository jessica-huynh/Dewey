//
//  AnalyzeImageResponse.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct AnalyzeImageResponse: Codable {
    let colourAnalysis: ColourAnalysis
    
    enum CodingKeys: String, CodingKey {
        case colourAnalysis = "colors"
    }
}

extension AnalyzeImageResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(AnalyzeImageResponse.self, from: data)
    }
}
