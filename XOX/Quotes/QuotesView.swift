//
//  QuotesView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import SwiftUI

struct QuotesView: View {
    
    @StateObject private var vm: QuotesViewModel = QuotesViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("\"\(vm.retrieveQuote())\"")
                    .italic()
                    .minimumScaleFactor(0.01)
                Spacer()
            }
            Text("")
            HStack {
                Text("- \(vm.retrieveAuthor())")
                    .italic()
                Spacer()
            }
                
        }
        .padding()
        
        
    }
}

#Preview {
    QuotesView()
}
