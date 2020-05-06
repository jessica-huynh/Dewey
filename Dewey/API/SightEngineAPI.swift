//
//  SightEngineAPI.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//
import Foundation
import Moya
import Keys

enum SightEngineAPI {
    static let provider = MoyaProvider<SightEngineAPI>()
    static let apiKeys = DeweyKeys()
    case analyzeImage(url: String)
}

extension SightEngineAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.sightengine.com/1.0/check.json")!
    }

    public var path: String {
        switch self {
        case .analyzeImage:
            return ""
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
        case .analyzeImage(let url):
            return .requestParameters(
                parameters: [
                    "models" : "properties",
                    "api_user": SightEngineAPI.apiKeys.user,
                    "api_secret": SightEngineAPI.apiKeys.secret,
                    "url": url],
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

extension SightEngineAPI {
    // MARK: - API request helper function
    static func request(for endpoint: SightEngineAPI, onSuccess: @escaping (Response) throws -> Void) {
        SightEngineAPI.provider.request(endpoint) {
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
