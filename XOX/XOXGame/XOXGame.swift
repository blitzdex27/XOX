//
//  XOXGame.swift
//  XOX
//
//  Created by Dexter Ramos on 10/9/23.
//

import Foundation

struct XOXGame {
    
    private let startingPiece: XOXPiece
    
    private var board: Board<XOXPiece>
    
    private var previousPiece: XOXPiece?
    
    private var previousLocation: Location?
    
    private let pieceMatchCountToWin: Int
    
    init(config: Config) {
        self.startingPiece = config.startingPiece
        self.board = Board<XOXPiece>(columns: config.columns, rows: config.rows)
        self.pieceMatchCountToWin = config.pieceMatchCountToWin
    }
    
    
    var pieces: [XOXPiece] {
        board.spots.compactMap { $0.piece }
    }
    
    var maxPieceSpots: Int {
        board.maxSpots
    }
    
    var boardSize: (columns: Int, rows: Int) {
        return board.size
    }
    
    mutating func put(on location: Location) throws {
        
        if let previousPiece = previousPiece {
            let nextPiece = previousPiece.nextPiece()
            try board.put(previousPiece.nextPiece(), on: location)
            self.previousPiece = nextPiece
        } else {
            try board.put(startingPiece, on: location)
            self.previousPiece = startingPiece
        }
        self.previousLocation = location
    }
    
    func piece(for location: Location) -> XOXPiece? {
        if let spot = board.spot(for: location),
           let piece = spot.piece
        {
            return piece
        }
        return nil
    }
    
    func boardSpot(for location: Location) -> Board<XOXPiece>.Spot? {
        return board.spot(for: location)
    }
    
    func checkIfWin() -> Bool {
        
        guard let previousPiece = previousPiece,
              let previousLocation = previousLocation
        else {
            return false
        }

        
        /// horizontal win check
        if checkHorizontalWin(for: previousPiece, on: previousLocation) {
            return true
        }
        /// vertical win check
        if checkVerticalWin(for: previousPiece, on: previousLocation) {
            return true
        }
        
        // diagonal up win check
        if checkDiagonalUpWin(for: previousPiece, on: previousLocation) {
            return true
        }
        
        // diagonal down win check
        if checkDiagonalDownWin(for: previousPiece, on: previousLocation) {
            return true
        }
        
        return false
        
    }
    
    private func checkDiagonalDownWin(for piece: XOXPiece, on location: Location) -> Bool {
        var diagonalDownCount = 1
        
        var _location = location
        
        // rightwards
        while _location.x < board.size.columns,
              _location.y < board.size.rows
        {
            
            _location = Location(x: _location.x + 1, y: _location.y + 1)
            
            if let pieceOnSpot = board.spot(for: _location)?.piece,
               pieceOnSpot == piece
            {
                diagonalDownCount += 1
                if diagonalDownCount >= pieceMatchCountToWin {
                    return true
                }
            }
            
            
            
        }
        
        
        // leftwards
        
        _location = location
        
        while _location.x > 1 && _location.y > 1
        {
            _location = Location(x: _location.x - 1, y: _location.y - 1)
            
            if let pieceOnSpot = board.spot(for: _location)?.piece,
               pieceOnSpot == piece
            {
                diagonalDownCount += 1
                if diagonalDownCount >= pieceMatchCountToWin {
                    return true
                }
            }
            
            
            
        }
        
        return false
        
    }
    
    private func checkDiagonalUpWin(for piece: XOXPiece, on location: Location) -> Bool {
        var diagonalUpCount = 1
        
        var _location = location
        
        // rightwards
        while _location.y > 1,
              _location.x < board.size.columns
        {
            
            _location = Location(x: _location.x + 1, y: _location.y - 1)
            
            if let pieceOnSpot = board.spot(for: _location)?.piece,
               pieceOnSpot == piece
            {
                diagonalUpCount += 1
                if diagonalUpCount >= pieceMatchCountToWin {
                    return true
                }
            }
            
            
            
        }
        
        
        // leftwards
        
        _location = location
        
        while _location.x > 1 && _location.y < board.size.rows
        {
            _location = Location(x: _location.x - 1, y: _location.y + 1)
            
            if let pieceOnSpot = board.spot(for: _location)?.piece,
               pieceOnSpot == piece
            {
                diagonalUpCount += 1
                if diagonalUpCount >= pieceMatchCountToWin {
                    return true
                }
            }
            
            
            
        }
        
        return false
        
    }
    
    private func checkHorizontalWin(for piece: XOXPiece, on location: Location) -> Bool {
        var horizontalCount = 0
        var unit = 1
        
        while unit <= board.size.columns {
            
            if let pieceOnSpot = board.spot(for: Location(x: unit, y: location.y))?.piece,
               pieceOnSpot == piece
            {
                horizontalCount += 1
                if horizontalCount >= pieceMatchCountToWin {
                    return true
                }
            }
            
            
            unit += 1
        }
        return false
    }
    
    private func checkVerticalWin(for piece: XOXPiece, on location: Location) -> Bool {
        var verticalCount = 0
        var unit = 1
        
        while unit <= board.size.rows {
            
            if let pieceOnSpot = board.spot(for: Location(x: location.x, y: unit))?.piece,
               pieceOnSpot == piece
            {
                verticalCount += 1
                if verticalCount >= pieceMatchCountToWin {
                    return true
                }
            }
            
            
            unit += 1
        }
        return false
    }
    
}

struct XOXPiece: Piece {
    var value: Variation
    
    init(value: Variation) {
        self.value = value
    }
    
    func nextPiece() -> XOXPiece {
        return XOXPiece(value: value.toggle())
    }
    
    
    enum Variation {
        case x
        case o
        
        func toggle() -> Self {
            switch self {
            case .x:
                return .o
            case .o:
                return .x
            }
        }
    }
}

protocol Piece: Equatable {
    associatedtype PieceType: Equatable
    var value: PieceType { get set }
    
}

struct Location {
    let x: Int
    let y: Int
}

struct Board<T: Piece> {
    
    init(columns: Int, rows: Int) {
        
        self.size = (columns, rows)
        
        var spots = [Board.Spot]()
        
        for column in 1...columns {
            
            for row in 1...rows {
                spots.append(Board.Spot(location: Location(x: column, y: row)))
            }
        }
        
        self.spots = spots
    }
    var spots: [Spot]
    
    var size: (columns: Int, rows: Int)
    
    
    
    var maxSpots: Int {
        spots.count
    }
    
    
    
    mutating func put(_ piece: T, on location: Location) throws {
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
        var piece: T?
        let location: Location
    }
    
    enum Error: Swift.Error {
        case locationOccupied
    }

}


extension Location: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        let condition1 = lhs.x == rhs.x
        let condition2 = lhs.y == rhs.y
        return condition1 && condition2
    }
}

extension XOXGame {
    struct Config {
        let startingPiece: XOXPiece
        let columns: Int
        let rows: Int
        let pieceMatchCountToWin: Int
    }
}
