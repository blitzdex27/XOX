//
//  ContentView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/9/23.
//

import SwiftUI

struct ContentView: View {
    private let xoxGameVM = XOXGameViewModel()
    
    private let quotesVM: QuotesViewModel = {
        return QuotesViewModel()
    }()
  
    var body: some View {
        NavigationView {
            VStack {
                QuotesView(vm: quotesVM)

                XOXGameView(vm: xoxGameVM)

                Button{
                    xoxGameVM.resetGame()
                } label: {
                    Image(.newgame)
                        .resizable()
                        .modifier(ColorInvertModifier(isReversed: true))
                }
                .foregroundStyle(.primary)

            }
            .navigationTitle("XOX")
            .modifier(SpecialNavbar())
        }
        
    }
}

struct SpecialNavbar: ViewModifier {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "FingerPaint-Regular", size: 40)!]
    }
    func body(content: Content) -> some View {
        return content
    }
}



#Preview {
    ContentView()
}
