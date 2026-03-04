//
//  QuotesView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import SwiftUI

struct QuotesView: View {
    
    @StateObject private var vm: QuotesViewModel = QuotesViewModel()
    
    var quoteContent: String {
        vm.isLoading ?
        "We all have the innate capacity to feel free." :
        "\"\(vm.retrieveQuote())\""
    }
    var authorContent: String {
        vm.isLoading ?
        "Beth Kempton" :
        "- \(vm.retrieveAuthor())"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(quoteContent)
                    .italic()
                    .minimumScaleFactor(0.01)
                Spacer()
            }
            Text("")
            HStack {
                Text(authorContent)
                    .italic()
                Spacer()
            }
                
        }
        .padding()
        .redacted(reason: vm.isLoading ? .placeholder : [])
        
        
    }
}

#Preview {
    QuotesView()
}
