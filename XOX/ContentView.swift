//
//  ContentView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/9/23.
//

import SwiftUI

struct ContentView: View {
    private let xoxGameVM = XOXGameViewModel(startingPiece: .x, columns: 3, rows: 3, pieceMatchCountToWin: 3)
    
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
                    Image("newgame")
                        .resizable()
                        .modifier(ColorInvertModifier(isReversed: true))
                }
                .foregroundStyle(.primary)

            }

            .navigationTitle("XOX")
            .modifier(SpecialNavbar())
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink("Config >") {
                        ConfigView()
                    }
                }
            }
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
