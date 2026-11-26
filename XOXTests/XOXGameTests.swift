//
//  XOXGameTests.swift
//  XOXTests
//

import Testing
@testable import XOX

/// After each move, the game checks only the lines that go through that move.
/// These tests play moves on real games and ask the game whether the last move won.
@Suite("Win check")
struct XOXGameTests {

    @Test("A new game has no win")
    func newGameHasNoWin() {
        let won = XOXGame().checkIfWin()
        #expect(!won)
    }

    @Test("A line away from the board's edges wins", arguments: [
        Position("across, columns 2 to 4", """
            . X X x .
            O O . . .
            . . . . .
            . . . . .
            . . . . .
            """),
        Position("across, columns 3 to 5, finished at its left end", """
            . . x X X
            O O . . .
            . . . . .
            . . . . .
            . . . . .
            """),
        Position("across the middle row, finished in the middle", """
            . . . . .
            O . . . O
            . X x X .
            . . . . .
            . . . . .
            """),
        Position("down, rows 3 to 5, under the other piece", """
            O . . . .
            O . . . .
            X . . . .
            X . . . .
            x . . . .
            """),
        Position("down the middle column, finished in the middle", """
            . . . . .
            O . X . .
            . . x . .
            O . X . .
            . . . . .
            """),
        Position("four to win, across, columns 2 to 5", toWin: 4, """
            O . O . O
            . . . . .
            . X X X x
            . . . . .
            . . . . .
            """),
        Position("four to win, down rows 2 to 5 of a 4 × 5 board", toWin: 4, """
            O . O .
            X . . .
            X O . .
            X . . .
            x . . .
            """),
    ])
    func lineAwayFromTheEdgesWins(_ position: Position) throws {
        let wins = try position.lastMoveWins()
        #expect(wins)
    }

    @Test("Lines that were already found still win", arguments: [
        Position("3 × 3, the top row", """
            x X X
            O O .
            . . .
            """),
        Position("3 × 3, the left column", """
            X O .
            x O .
            X . .
            """),
        Position("3 × 3, the diagonal down", """
            X O O
            . x .
            . . X
            """),
        Position("3 × 3, the diagonal up", """
            O O X
            . x .
            X . .
            """),
        Position("5 × 5, across from the left edge", """
            X X x . .
            O O . . .
            . . . . .
            . . . . .
            . . . . .
            """),
        Position("5 × 5, down from the top edge", """
            X O . . .
            X O . . .
            x . . . .
            . . . . .
            . . . . .
            """),
        Position("5 × 5, a diagonal in the middle", """
            . . . . .
            . X . . .
            O . x . .
            O . . X .
            . . . . .
            """),
        Position("5 × 5, four to win, a diagonal up", toWin: 4, """
            O . O . .
            . . . . X
            . . . X .
            . . x . O
            . X . . .
            """),
    ])
    func linesThatAlreadyWonStillWin(_ position: Position) throws {
        let wins = try position.lastMoveWins()
        #expect(wins)
    }

    @Test("No false wins", arguments: [
        Position("a gap, then two more, to the right and below", """
            x . X X .
            . . . . O
            X . . . .
            X . O . .
            . O . O .
            """),
        Position("a gap, then two more, to the left and above", """
            . O . O .
            . . O . X
            O . . . X
            . . . . .
            . X X . x
            """),
        Position("the other piece, then two more, to the right and below", """
            x O X X .
            O . . . .
            X . . . O
            X . O . .
            . . . . .
            """),
        Position("the other piece, then two more, to the left and above", """
            . . . . .
            O . . . X
            . . O . X
            . . . . O
            . X X O x
            """),
        Position("across, next to two of the other piece", """
            . O O x .
            X . . . .
            . . . . .
            . . . . .
            . . . . .
            """),
        Position("down, under two of the other piece", """
            . O . . .
            . O . . .
            . x . . .
            . . . . .
            . . . . X
            """),
        Position("three in a row when four win", toWin: 4, """
            . X X x .
            O O . . .
            . . . . .
            . . . . .
            . . . . .
            """),
        Position("no wrapping from the end of one row to the next", """
            . . . X X
            x . . . .
            O O . . .
            . . . . .
            . . . . .
            """),
        Position("no wrapping from the bottom of one column to the next", """
            . x . . .
            . . . . .
            . . . . .
            X . . . O
            X . . . O
            """),
    ])
    func noFalseWin(_ position: Position) throws {
        let wins = try position.lastMoveWins()
        #expect(!wins)
    }

    @Test("Every line wins, on every board the Config screen allows",
          arguments: GameSetup.all, [XOXPiece.Variation.x, .o])
    func everyLineWins(on setup: GameSetup, startingWith first: XOXPiece.Variation) throws {
        let lines = setup.lines
        // Across, down and both diagonals each fit on the board in so many places.
        let across = setup.columns - setup.toWin + 1
        let down = setup.rows - setup.toWin + 1
        #expect(lines.count == setup.rows * across + setup.columns * down + 2 * across * down)

        for line in lines {
            // The other piece plays off the line, and too few times to make a line of its own.
            let elsewhere = setup.squares.filter { !line.contains($0) }
            for finish in line.indices {
                var moves = line
                moves.append(moves.remove(at: finish))
                var game = setup.newGame(startingWith: first)
                for (turn, square) in moves.enumerated() {
                    if turn > 0 {
                        try game.put(on: elsewhere[turn - 1])
                        let won = game.checkIfWin()
                        #expect(!won, "the other piece won at \(elsewhere[turn - 1].label)")
                    }
                    try game.put(on: square)
                    if turn < moves.count - 1 {
                        let won = game.checkIfWin()
                        #expect(!won, "won early, after \(label(moves.prefix(turn + 1)))")
                    }
                }
                let won = game.checkIfWin()
                #expect(won, "\(label(line)), finished at \(moves.last!.label)")
            }
        }
    }

    @Test("Random games agree with a check of every line on the board", arguments: GameSetup.all)
    func randomGamesAgree(on setup: GameSetup) throws {
        let lines = setup.lines
        var random = SplitMix64(seed: UInt64(setup.columns * 100 + setup.rows * 10 + setup.toWin))
        for _ in 1...100 {
            var game = setup.newGame()
            var moves: [Location] = []
            for square in setup.squares.shuffled(using: &random) {
                try game.put(on: square)
                moves.append(square)
                let mover = try #require(game.piece(for: square))
                // The game stops at its first win, so a line of the mover's anywhere is a line made by this move.
                let made = lines.contains { line in line.allSatisfy { game.piece(for: $0) == mover } }
                let won = game.checkIfWin()
                #expect(won == made, "after \(label(moves))")
                if made { break }
            }
        }
    }
}

// MARK: - Helpers

/// A board size and win count, as picked on the Config screen.
struct GameSetup: CustomTestStringConvertible, Sendable {
    let columns: Int
    let rows: Int
    let toWin: Int

    /// Every setup the Config screen offers: 3, 4 or 5 columns and rows,
    /// and from 3 up to the smaller of the two in a row to win.
    static let all: [GameSetup] = [3, 4, 5].flatMap { columns in
        [3, 4, 5].flatMap { rows in
            (3...min(columns, rows)).map { GameSetup(columns: columns, rows: rows, toWin: $0) }
        }
    }

    var testDescription: String { "\(columns) × \(rows), \(toWin) to win" }

    func newGame(startingWith first: XOXPiece.Variation = .x) -> XOXGame {
        XOXGame(config: .init(startingPiece: XOXPiece(value: first),
                              columns: columns,
                              rows: rows,
                              pieceMatchCountToWin: toWin))
    }

    /// Every square, in reading order.
    var squares: [Location] {
        (1...rows).flatMap { y in (1...columns).map { x in Location(x: x, y: y) } }
    }

    /// Every run of `toWin` squares in a straight line: across, down, and both diagonals.
    var lines: [[Location]] {
        let steps = [(x: 1, y: 0), (x: 0, y: 1), (x: 1, y: 1), (x: 1, y: -1)]
        return squares.flatMap { start in
            steps.compactMap { step in
                let line = (0..<toWin).map { Location(x: start.x + $0 * step.x, y: start.y + $0 * step.y) }
                return line.allSatisfy(isOnBoard) ? line : nil
            }
        }
    }

    func isOnBoard(_ square: Location) -> Bool {
        (1...columns).contains(square.x) && (1...rows).contains(square.y)
    }
}

/// A position drawn as a board: one line per row, with a space between squares.
/// `.` is an empty square, `X` and `O` are earlier moves, and the one lowercase `x` or `o` is the last move.
struct Position: CustomTestStringConvertible, Sendable {
    let name: String
    let toWin: Int
    let board: String

    init(_ name: String, toWin: Int = 3, _ board: String) {
        self.name = name
        self.toWin = toWin
        self.board = board
    }

    var testDescription: String { name }

    /// Plays the position on a new game, with the last move last, and says whether that move wins.
    ///
    /// The earlier moves take turns, each piece's in reading order, and none of them may win.
    /// The piece that started is the one that makes the moves come out even.
    func lastMoveWins(sourceLocation: SourceLocation = #_sourceLocation) throws -> Bool {
        let rows = board.split(separator: "\n").map { $0.split(separator: " ") }
        var earlier: [XOXPiece.Variation: [Location]] = [.x: [], .o: []]
        var last: (piece: XOXPiece.Variation, square: Location)?
        for (y, row) in rows.enumerated() {
            for (x, mark) in row.enumerated() {
                let square = Location(x: x + 1, y: y + 1)
                switch mark {
                case ".":
                    break
                case "X":
                    earlier[.x]!.append(square)
                case "O":
                    earlier[.o]!.append(square)
                case "x", "o":
                    guard last == nil else { throw BadPosition("\(name): more than one last move") }
                    last = (piece: mark == "x" ? .x : .o, square: square)
                default:
                    throw BadPosition("\(name): unknown mark \(mark)")
                }
            }
        }
        guard let last else { throw BadPosition("\(name): no last move") }
        let columns = rows[0].count
        guard rows.allSatisfy({ $0.count == columns }) else { throw BadPosition("\(name): rows of different lengths") }

        let mover = last.piece
        let mine = earlier[mover]!
        let theirs = earlier[mover.toggle()]!
        let first: XOXPiece.Variation
        let moves: [Location]
        if mine.count == theirs.count {
            first = mover
            moves = zip(mine, theirs).flatMap { pair in [pair.0, pair.1] }
        } else if theirs.count == mine.count + 1 {
            first = mover.toggle()
            moves = zip(theirs, mine).flatMap { pair in [pair.0, pair.1] } + [theirs.last!]
        } else {
            throw BadPosition("\(name): \(mine.count) earlier \(mover.rawValue)s and \(theirs.count) of the other can't take turns")
        }

        var game = XOXGame(config: .init(startingPiece: XOXPiece(value: first),
                                         columns: columns,
                                         rows: rows.count,
                                         pieceMatchCountToWin: toWin))
        for square in moves {
            try game.put(on: square)
            let won = game.checkIfWin()
            #expect(!won, "\(name): an earlier move won, at \(square.label)", sourceLocation: sourceLocation)
        }
        try game.put(on: last.square)
        return game.checkIfWin()
    }
}

struct BadPosition: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}

/// A seeded random number generator, so that every run plays the same games.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

extension Location {
    /// The square as (column, row), for messages.
    var label: String { "(\(x), \(y))" }
}

func label<S: Sequence>(_ squares: S) -> String where S.Element == Location {
    squares.map(\.label).joined(separator: " ")
}
