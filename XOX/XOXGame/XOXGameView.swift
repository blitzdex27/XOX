//
//  XOXGameView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import SwiftUI

struct XOXGameView: View {
    
    init(vm: XOXGameViewModel) {
        self.vm = vm
    }
    
    @ObservedObject private var vm: XOXGameViewModel
    
    @State private var isAlertShow = false
    
    @State private var isWinAlertShow = false
    
    @State private var isReachedMaxAlertShow = false
    
    var body: some View {
        
        LazyVGrid(columns: Array(repeating: GridItem(), count: vm.boardSize.columns)) {
            
            ForEach(1...vm.boardSize.rows, id: \.self) { row in
                
                ForEach(1...vm.boardSize.columns, id: \.self) { column in
                    XOXBlockView(spot: vm.boardSpot(for: .init(x: column, y: row)),
                                 imageSelection: vm.spotImageSelection,
                                 handler: XOXBlockHandler(_:location:))
                }
            }
            
        }
        .padding(.init(top: 10, leading: 50, bottom: 0, trailing: 50))
        
        
        .alert("Notice", isPresented: $isAlertShow) {
            Button("Ok") {
                isAlertShow = false
            }
        } message: {
            Text("Changing piece is prohibited")
        }
        .alert("Game Over", isPresented: $isWinAlertShow) {
            Button("Ok") {
                isWinAlertShow = false
                vm.resetGame()
            }
        } message: {
            Text("You have won")
        }
        .alert("Game Over", isPresented: $isReachedMaxAlertShow) {
            Button("Ok") {
                isReachedMaxAlertShow = false
                vm.resetGame()
            }
        } message: {
            Text("Reached maximum board spots limit")
            Text("Game will reset")
        }
        
    }
    
    private func XOXBlockHandler(_ value: String, location: Location) {
        do {
            try vm.put(on: location)
            if vm.checkIfWin() {
                isWinAlertShow = true
                return
            }
            
            if vm.reachedMaxNumberOfPieces {
                isReachedMaxAlertShow = true
            }
            
        } catch {
            isAlertShow = true
        }
    }
    

}

#Preview {
    XOXGameView(vm: XOXGameViewModel())
}
