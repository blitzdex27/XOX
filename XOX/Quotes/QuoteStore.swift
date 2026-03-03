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
            /// Check if last fetch does not exists or more than the set quote duration
            /// Fetch if true
            if isLastFetchTimeMoreThan(quoteDuration: quoteDuration),
               let quote = try await fetchQuote() {
                saveQuote(quote)
                return quote
            }
            
            /// Get stored quote or fallback to default
            return loadStoredQuote() ?? .default
        } catch {
            /// Get stored quote or fallback to default
            return loadStoredQuote() ?? .default
        }

    }
    
    private func fetchQuote() async throws -> QuoteModel? {
        let data = try await APIFetcher.shared.sendGet(url, queries: nil, headers: [
            "X-Api-Key": apiKey
        ])
        
        let quotes = try JSONDecoder().decode([QuoteModel].self, from: data)
        return quotes.first
    }
    
    private func saveQuote(_ quote: QuoteModel) {
        if let encoded = try? JSONEncoder().encode(quote) {
            UserDefaults.standard.set(encoded, forKey: storeKey)
            UserDefaults.standard.set(Date(), forKey: lastFetchDateStoreKey)
        }
    }
    
    private func loadStoredQuote() -> QuoteModel? {
        if let data = UserDefaults.standard.value(forKey: storeKey) as? Data,
           let decoded = try? JSONDecoder().decode(QuoteModel.self, from: data) {
            return decoded
        }
        return nil
    }
    
    private func isLastFetchTimeMoreThan(quoteDuration: Double) -> Bool {
        if let lastFetchDate = UserDefaults.standard.object(forKey: lastFetchDateStoreKey) as? Date {
            return Date().timeIntervalSince(lastFetchDate) > quoteDuration
        } else {
            return true
        }
    }
}
