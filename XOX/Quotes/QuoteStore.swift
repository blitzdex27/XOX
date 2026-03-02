//
//  QuoteStore.swift
//  XOX
//
//  Created by Dexter on 3/3/26.
//
import Foundation

class QuoteStore {
    private let url = "https://api.api-ninjas.com/v2/quoteoftheday"
    private let apiKey = "cr6zOQFiaAoqh2StJZaPR11uqXIQk8JKnXj1FjoP"
    private let quoteDuration: Double = 3600 * 24
    private let storeKey = "QuoteStore"
    private let lastFetchDateStoreKey = "lastFetchDateStoreKey"
    
    func getQuote() async -> QuoteModel {
        do {
            if let quoteData = UserDefaults.standard.data(forKey: storeKey) {
                let quote = try JSONDecoder().decode(QuoteModel.self, from: quoteData)
                
                if let lastFetchDate = UserDefaults.standard.value(forKey: lastFetchDateStoreKey) as? Date,
                   Date().timeIntervalSince(lastFetchDate) > quoteDuration {
                    return try await fetchQuote() ?? .default
                } else {
                    return quote
                }
                
                
            } else {
                return try await fetchQuote() ?? .default
            }
        } catch {
            return .default
        }

    }
    
    private func fetchQuote() async throws -> QuoteModel? {
        let data = try await APIFetcher.shared.sendGet(url, queries: nil, headers: [
            "X-Api-Key": apiKey
        ])
        
        let quotes = try JSONDecoder().decode([QuoteModel].self, from: data)
        UserDefaults.standard.set(Date(), forKey: lastFetchDateStoreKey)
        return quotes.first
    }
}
