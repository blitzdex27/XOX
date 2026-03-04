//
//  QuoteModel.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

struct QuoteModel: Codable {
    
    let quote: String
    let author: String
    
    static var `default`: Self {
        QuoteModel(quote: "The most beautiful thing we can experience is the mysterious.", author: "Albert Einstein")
    }
}
