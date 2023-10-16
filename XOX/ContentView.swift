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
            .modifier(XOXConfigToolbarModifier($isConfigPresented, xoxVm: $xoxGameVM))
            .modifier(XOXFullScreenToolbarModifier($isFullScreenPresented, xoxVm: $xoxGameVM, mode: .embed))
            .popover(isPresented: $isConfigPresented, content: {
                ConfigView()
            })
            .fullScreenCover(isPresented: $isFullScreenPresented, content: {
                NavigationView {
                    XOXGameView(vm: xoxGameVM)
                        .padding()
                        .navigationTitle("XOX")
                        .modifier(XOXConfigToolbarModifier($isConfigPresented, xoxVm: $xoxGameVM))
                        .modifier(XOXFullScreenToolbarModifier($isFullScreenPresented, xoxVm: $xoxGameVM, mode: .full))
                }

            })

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

struct XOXConfigToolbarModifier: ViewModifier {
    
    @Binding private var isPresented: Bool
    
    @Binding private var xoxVm: XOXGameViewModel

    init(_ isPresented: Binding<Bool>, xoxVm: Binding<XOXGameViewModel>) {
        self._xoxVm = xoxVm
        self._isPresented = isPresented
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = true
                    } label: {
                        Image(systemName: "wrench.and.screwdriver")
                    }
                }
            }
        
    }
}

struct XOXFullScreenToolbarModifier: ViewModifier {
    
    @Binding private var isPresented: Bool
    
    private let mode: Mode
    
    @Binding private var xoxVm: XOXGameViewModel

    init(_ isPresented: Binding<Bool>, xoxVm: Binding<XOXGameViewModel>, mode: Mode) {
        self._xoxVm = xoxVm
        self._isPresented = isPresented
        self.mode = mode
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isPresented.toggle()
                       
                    } label: {
                        switch mode {
                        case .full:
                            Image(systemName: "arrow.down.backward.and.arrow.up.forward.square")
                        case .embed:
                            Image(systemName: "arrow.up.forward.and.arrow.down.backward.square")
                        }
                    }
                }
            }
        
    }
    
    enum Mode {
        case full
        case embed
    }
}


#Preview {
    ContentView()
}
