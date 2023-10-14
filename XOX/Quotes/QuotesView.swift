//
//  QuotesView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import SwiftUI

struct QuotesView: View {
    
    init(vm: QuotesViewModel) {
        self.vm = vm
    }
    
    @ObservedObject private var vm: QuotesViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("\"\(vm.retrieveQuote())\"")
                    .minimumScaleFactor(0.01)
                Spacer()
            }
            Text("")
            HStack {
                Text("- \(vm.retrieveAuthor())")
                Spacer()
            }
                
        }
        .italic()
        .padding()
        
        
    }
}

#Preview {
    QuotesView(vm: .init())
}
