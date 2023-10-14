//
//  Fetcher.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

class APIFetcher {
    static let shared = APIFetcher()
    
    func sendGet(_ urlString: String, completion: @escaping (_ data: Data, _ responseObject: Any) -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        guard let url = URL(string: urlString) else {
            failure(Error.invalidUrl(urlString))
            return
        }
        
        
        
        let dataTask = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    failure(Error.unknownError(error!.localizedDescription))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(Error.noDataReceived)
                }
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) else {
                DispatchQueue.main.async {
                    failure(Error.unableToSerializeData)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(data, json)
            }
            return
        }
        
        dataTask.resume()
    }
}

extension APIFetcher {
    enum Error: Swift.Error {
        case invalidUrl(_ url: String)
        case unknownError(_ error: String)
        case noDataReceived
        case unableToSerializeData
    }
}
