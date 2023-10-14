//
//  XOXGameViewModel.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

class XOXGameViewModel: ObservableObject {
    private var xoxGame = XOXGame()
    
    @Published var pieces = [Piece]()
    
    var spotImageSelection = (blank: 5, occupied: 1)
    
    var reachedMaxNumberOfPieces: Bool {
        pieces.count == xoxGame.maxPieceSpots
    }
    
    func put(_ piece: Piece, on location: Location) throws {
        try xoxGame.put(piece: piece, on: location)
        pieces = xoxGame.pieces
    }
    
    func pieceValue(x: Int, y: Int) -> String? {
        if let piece = xoxGame.piece(for: Location(x: x, y: y)) {
            return piece.value
        } else {
            return nil
        }
    }
    
    func boardSpot(for location: Location) -> Board.Spot? {
        xoxGame.boardSpot(for: location)
    }
    
    func checkIfWin() -> Bool {
        xoxGame.checkIfWin()
    }
    
    func resetGame() {
        xoxGame = XOXGame()
        changeSpotImageSelection()
        pieces = []
        
    }
    
    private func changeSpotImageSelection() {
        let blank = Int.random(in: 1...7)
        let occupied = Int.random(in: 1...4)
        spotImageSelection = (blank, occupied)
    }
    
}

extension Array where Element == Piece {
//    func value(_ location: Location) -> String {
//
//        if let piece = self.first(where: { $0.location == location }) {
//            return piece.value
//        } else {
//            return ""
//        }
//    }
}
