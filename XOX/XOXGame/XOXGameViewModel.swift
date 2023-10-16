//
//  XOXGameViewModel.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import Foundation

class XOXGameViewModel: ObservableObject {
    
    init(startingPieceVariation: XOXPiece.Variation, columns: Int = 3, rows: Int = 3, pieceMatchCountToWin: Int = 3) {
        
        let config = XOXGame.Config(
            startingPiece: XOXPiece(value: startingPieceVariation),
            columns: columns,
            rows: rows,
            pieceMatchCountToWin: pieceMatchCountToWin
        )
        
        currentGame = XOXGame(config: config)
        xoxGame = currentGame
        self.boardSize = currentGame.boardSize
    }
    
    private let currentGame: XOXGame
    
    @Published private var xoxGame: XOXGame
    
    var spotImageSelection = (blank: 5, occupied: 1)
    
    var reachedMaxNumberOfPieces: Bool {
        xoxGame.pieces.count == xoxGame.maxPieceSpots
    }
    
    let boardSize: (columns: Int, rows: Int)
    
    func put(on location: Location) throws {
        try xoxGame.put(on: location)
    }
    
    func pieceValue(x: Int, y: Int) -> XOXPiece.Variation? {
        if let piece = xoxGame.piece(for: Location(x: x, y: y)) {
            return piece.value
        } else {
            return nil
        }
    }
    
    func boardSpot(for location: Location) -> Board<XOXPiece>.Spot? {
        xoxGame.boardSpot(for: location)
    }
    
    func checkIfWin() -> Bool {
        xoxGame.checkIfWin()
    }
    
    func resetGame() {
        xoxGame = currentGame
        changeSpotImageSelection()
    }
    
    private func changeSpotImageSelection() {
        let blank = Int.random(in: 1...7)
        let occupied = Int.random(in: 1...4)
        spotImageSelection = (blank, occupied)
    }
    
}


