//
//  XOXGame.swift
//  XOX
//
//  Created by Dexter Ramos on 10/9/23.
//

import Foundation

struct XOXGame {
    
    private var board: Board = {
        var board = Board.makeBoard(columns: 3, rows: 3)
        var winningCombinations = [Board.WinSpotCombination]()
        
        /// Horizontal combinations
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 1)),
            .init(piece: Piece(value: "o"), location: Location(x: 1, y: 2)),
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 3)),
        ]))
        
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 2, y: 1)),
            .init(piece: Piece(value: "o"), location: Location(x: 2, y: 2)),
            .init(piece: Piece(value: "x"), location: Location(x: 2, y: 3)),
        ]))
        
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 1)),
            .init(piece: Piece(value: "o"), location: Location(x: 3, y: 2)),
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 3)),
        ]))
        
        /// Vertical combinations
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 1)),
            .init(piece: Piece(value: "o"), location: Location(x: 2, y: 1)),
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 1)),
        ]))
        
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 2)),
            .init(piece: Piece(value: "o"), location: Location(x: 2, y: 2)),
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 2)),
        ]))
        
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 3)),
            .init(piece: Piece(value: "o"), location: Location(x: 2, y: 3)),
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 3)),
        ]))
        
        /// Diagonal combinations
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 1)),
            .init(piece: Piece(value: "o"), location: Location(x: 2, y: 2)),
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 3)),
        ]))
        
        winningCombinations.append(.init(spots: [
            .init(piece: Piece(value: "x"), location: Location(x: 1, y: 3)),
            .init(piece: Piece(value: "o"), location: Location(x: 2, y: 2)),
            .init(piece: Piece(value: "x"), location: Location(x: 3, y: 1)),
        ]))
        
        board.winSpotCombinations = winningCombinations
        return board
    }()
    
    var pieces: [Piece] {
        board.spots.compactMap { $0.piece }
    }
    
    var maxPieceSpots: Int {
        board.maxSpots
    }

    mutating func put(piece: Piece, on location: Location) throws {
        try board.put(piece, on: location)
    }
    
    func piece(for location: Location) -> Piece? {
        if let spot = board.spot(for: location),
           let piece = spot.piece
        {
            return piece
        }
        return nil
    }
    
    func boardSpot(for location: Location) -> Board.Spot? {
        return board.spot(for: location)
    }
    
    func checkIfWin() -> Bool {
        board.isWin
    }
 }


struct Piece {
    let value: String
}

struct Location {
    let x: Int
    let y: Int
}

struct Board {
    var spots: [Spot]
    
    var winSpotCombinations: [WinSpotCombination] = []
    
    var maxSpots: Int {
        spots.count
    }
    
    var isWin: Bool {
        for winSpotCombination in winSpotCombinations {
            
            if winSpotCombination.checkIfWon(spots: spots.filter { $0.piece != nil }) {
                return true
            }
            
        }
        return false
    }
    
    mutating func put(_ piece: Piece, on location: Location) throws {
        guard spots.contains(where: {
            let condition1 =  $0.location == location
            let condition2 = $0.piece == nil
            return condition1 && condition2
        })  else {
            throw Error.locationOccupied
        }
        
        if let index = spots.firstIndex(where: { $0.location == location }) {
            spots[index] = .init(piece: piece, location: location)
        }
    }
    
    func spot(for location: Location) -> Spot? {
        return spots.first(where: { $0.location == location })
    }
    
    
    
    struct Spot {
        var piece: Piece?
        let location: Location
    }
    
    enum Error: Swift.Error {
        case locationOccupied
    }

    struct WinSpotCombination {
        let spots: [Spot]
        init(spots: [Spot]) {
            self.spots = spots
        }
        
        func checkIfWon(spots: [Spot]) -> Bool {
            
            for spot in self.spots {
                if !spots.contains(where: { $0.piece == spot.piece && $0.location == spot.location }) {
                    return false
                }
            }
            return true
        }
    }
}

// MARK: - Board factory

extension Board {
    static func makeBoard(columns: Int, rows: Int) -> Board {
        
        var spots = [Board.Spot]()
        
        for column in 1...columns {
            
            for row in 1...rows {
                spots.append(Board.Spot(location: Location(x: column, y: row)))
            }
        }
        
        return Board(spots: spots)
        
    }
}

extension Location: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        let condition1 = lhs.x == rhs.x
        let condition2 = lhs.y == rhs.y
        return condition1 && condition2
    }
}

extension Piece: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
}
