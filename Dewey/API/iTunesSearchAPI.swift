//
//  iTunesSearchAPI.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-02.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import Moya

enum iTunesSearchAPI {
    static let provider = MoyaProvider<iTunesSearchAPI>()
    case search(query: String)
    case lookup(id: Int32)
}

extension iTunesSearchAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!    }

    public var path: String {
        switch self {
        case .search:
            return "/search"
        case .lookup:
            return "/lookup"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        switch self {
        case .search(let query):
            return .requestParameters(
                parameters: [
                    "term": query,
                    "country": NSLocale.current.regionCode!,
                    "media": "ebook"],
                encoding: URLEncoding.default)
        case .lookup(let id):
            return .requestParameters(
            parameters: [
                "id": id,
                "media": "ebook"],
            encoding: URLEncoding.default)
        }
    }

    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }

    public var validationType: ValidationType {
      return .successCodes
    }
}

extension iTunesSearchAPI {
    // MARK: - API request helper function
    static func request(for endpoint: iTunesSearchAPI, onSuccess: @escaping (Response) throws -> Void) {
        iTunesSearchAPI.provider.request(endpoint) {
            result in
            
            switch result {
            case .success(let response):
                do {
                    try onSuccess(response)
                } catch {
                    print("Error: \(error)")
                }
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
}
