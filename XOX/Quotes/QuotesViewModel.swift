//
//  QuotesViewModel.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

@MainActor
class QuotesViewModel: ObservableObject {
    
    @Published var quote: QuoteModel?
    private let store = QuoteStore()
    
    init() {
        Task {
            self.quote = await store.getQuote()
        }
    }
    
    

    
    func retrieveQuote() -> String {
        if let model = quote {
            return model.quote
        }
        return ""
    }
    
    func retrieveAuthor() -> String {
        if let model = quote {
            return model.author
        }
        return ""
    }
}
