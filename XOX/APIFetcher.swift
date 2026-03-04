//
//  Fetcher.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

class APIFetcher {
    static let shared = APIFetcher()
    
    
    func sendGet(_ urlString: String, queries: [URLQueryItem]?, headers: [String: String]?) async throws -> Data {
        
        guard var components = URLComponents(string: urlString),
              let url = components.url else {
            throw Error.invalidUrl(urlString)
        }
        
        if let queries {
            components.queryItems = queries
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        if let headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return data
    }
}

extension APIFetcher {
    enum Error: Swift.Error {
        case invalidUrl(_ url: String)
        case invalidQuery(_ query: String)
        case unknownError(_ error: String)
        case noDataReceived
        case unableToSerializeData
    }
}
