//
//  XOXConfigToolbarModifier.swift
//  XOX
//
//  Created by Dexter Ramos on 10/16/23.
//

import SwiftUI

struct SpecialNavbar: ViewModifier {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "FingerPaint-Regular", size: 40)!]
    }
    func body(content: Content) -> some View {
        return content
    }
}

struct XOXConfigToolbarModifier<ContentView: View>: ViewModifier {
    
    @State private var isPresented: Bool = false
    
    private let content: (Binding<Bool>) -> ContentView
    
    init(@ViewBuilder content: @escaping (_ isPresented: Binding<Bool>) -> ContentView) {
        self.content = content
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
            .popover(isPresented: $isPresented, content: {
                self.content($isPresented)
            })
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
                            Image(systemName: "arrow.up.forward.and.arrow.down.backward.square")
                        case .embed:
                            Image(systemName: "arrow.down.backward.and.arrow.up.forward.square")
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
