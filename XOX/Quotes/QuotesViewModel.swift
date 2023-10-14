//
//  QuotesViewModel.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

class QuotesViewModel: ObservableObject {
    
    @Published private var model: QuoteModel?
    
    
    private let url = "https://api.quotable.io/quotes/random"
    
    init(model: QuoteModel? = nil) {
        self.model = model
        fetchQuote()
    }
    
    
    func fetchQuote() {
        APIFetcher.shared.sendGet(url) { [weak self] data, responseObject in
            
            let decoder = JSONDecoder()
            if let quotes = try? decoder.decode([QuoteModel].self, from: data),
               let quote = quotes.first
            {
                self?.model = quote
            }
        } failure: { error in
            self.model = .init(content: "The most beautiful thing we can experience is the mysterious.", author: "Albert Einstein")
            print(error)
        }

    }
    
    func retrieveQuote() -> String {
        if let model = model {
            return model.content
        }
        return ""
    }
    
    func retrieveAuthor() -> String {
        if let model = model {
            return model.author
        }
        return ""
    }
}
