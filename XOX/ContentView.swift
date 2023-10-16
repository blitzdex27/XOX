//
//  ContentView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/9/23.
//

import SwiftUI

struct ContentView: View {
    @State private var xoxGameVM = XOXGameViewModel(
        startingPieceVariation: .x,
        columns: 3,
        rows: 3,
        pieceMatchCountToWin: 3)
    
    private let quotesVM: QuotesViewModel = {
        return QuotesViewModel()
    }()
    
    @State private var isFullScreenPresented: Bool = false
    
    @State private var isConfigPresented: Bool = false
  
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    QuotesView(vm: quotesVM)

                    XOXGameView(vm: xoxGameVM)
                        .padding(.init(top: 10, leading: 50, bottom: 0, trailing: 50))

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
                .modifier(XOXConfigToolbarModifier(content: { isPresented in
                    ConfigView(isPresented: isPresented, xoxVM: $xoxGameVM)
                }))
                .modifier(XOXFullScreenToolbarModifier($isFullScreenPresented, xoxVm: $xoxGameVM, mode: .embed))

                .fullScreenCover(isPresented: $isFullScreenPresented, content: {
                    NavigationView {
                        XOXGameView(vm: xoxGameVM)
                            .padding()
                            .navigationTitle("XOX")
                            .modifier(XOXConfigToolbarModifier(content: { isPresented in
                                ConfigView(isPresented: isPresented, xoxVM: $xoxGameVM)
                            }))
                            .modifier(XOXFullScreenToolbarModifier($isFullScreenPresented, xoxVm: $xoxGameVM, mode: .full))
                    }

                })
            }

        }
    }
}




#Preview {
    ContentView()
}
