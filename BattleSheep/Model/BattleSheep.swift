//
//  BattleSheep.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/9/21.
//

import Foundation

enum BoardStatus: Int {
    case blank = 0, sheep, hit, miss, sink
}

enum Responses: String {
    case prompt = "Enter a location to shear, e.g. 'A2', or type 'exit' to quit:"
    case exitGame = "exit"
    case gameOver = "You sheared all BattleSheep! Game Over. Thanks for playing! 🙏🏼"
    case invalidInput = "Invalid input. Try again."
    case miss = "You missed."
    case alreadyAttacked = "You've already sheared this location."
    case hit = "It's a hit!"
    case shearedBattleSheep = "You've sheared a BattleSheep!"
}

protocol BattleSheepDelegate {
    func didShearSheep(_ controller: BattleSheep)
}


struct BattleSheep: CustomStringConvertible {
    
    // MARK: - Computer AI Properties
    var cpuLastMove: (location: Coordinates, status: BoardStatus)!// = (Coordinates(row: 0, col: 0)!, .blank)
    var cpuNextMove: (location: Coordinates, status: BoardStatus)!
    var cpuFoundSheepInitialLocation: Coordinates?// = Coordinates(row: 0, col: 0)
    var cpuFoundSheepDirection: (lr: Int, ud: Int) = (1, 0)

    
    // MARK: - Properties
    static let boardSize = 10
    var totalAttacks = 0
    var totalHits = 0
    var board = [[BoardStatus]]()
    var sheeps = [Sheep]()
    var delegate: BattleSheepDelegate?
    
    var isGameOver: Bool {
        return sheepRemaining == 0 ? true : false
    }

    var sheepRemaining: Int {
        var count = 0
        
        for sheep in sheeps {
            if !sheep.isShorn {
                count += 1
            }
        }
        
        return count
    }

    var description: String {
        var strBoard = "  "
        
        //set column headers
        for (i, _) in board.enumerated() {
            let index = i + 1
            
            strBoard += ("\(index)".count < 2 ? " " : "") + "\(index)  "
        }
        strBoard += "\n  "
        
        for _ in board {
            strBoard += "--- "
        }
        strBoard += "\n"

        //set the rest of the board
        for (rowNum, row) in board.enumerated() {
            strBoard += "\(Character(UnicodeScalar(rowNum + Int(("A" as Unicode.Scalar).value))!))"

            for col in row {
                var thingToPrint = ""
                
                switch col {
                case .hit:
                    thingToPrint = "X"
                case .miss:
                    thingToPrint = "O"
                case .sink:
                    thingToPrint = "S"
                default:
                    thingToPrint = " "
                }
                
                strBoard += "| \(thingToPrint) "
            }
            strBoard += "|\n  "
            
            for _ in board {
                strBoard += "--- "
            }
            strBoard += "\n"
        }
        
        return strBoard
    }
    
    
    // MARK: - Methods
    init() {
        newGame()
    }
    
    mutating func newGame() {
        resetBoard()
        placeAllSheep()
    }
    
    func getRandomSpace() -> Int {
        return Int.random(in: 0..<BattleSheep.boardSize)
    }
    
    @discardableResult mutating func fire(at coordinates: Coordinates) -> BoardStatus? {
        return fire(at: coordinates.a1)
    }
    
    @discardableResult mutating func fire(at a1: String) -> BoardStatus? {
        guard !isGameOver else {
            print(Responses.gameOver.rawValue)
            return nil
        }
        
//        print("\n")
        
        guard let location = Coordinates(at: a1) else {
            return nil
        }
        
        
        //SUCCESS!
        switch board[location.row][location.col] {
        case .blank:
            board[location.row][location.col] = .miss
            totalAttacks += 1
//            print(Responses.miss.rawValue)
        case .miss, .hit, .sink:
//            print(Responses.alreadyAttacked.rawValue)
            return nil
        case .sheep:
            board[location.row][location.col] = .hit
            totalHits += 1
            totalAttacks += 1

            var stopCheckingSheep = false
            var didShearBattleSheep = false
            
            for (index, sheep) in sheeps.enumerated() {
                for (jndex, coordinates) in sheep.coordinates.enumerated() {
                    if location == coordinates {
                        sheeps[index].statuses[jndex] = .hit
                        
                        if sheeps[index].isShorn {
                            
                            //This feels inefficient but seems the only way to go???
                            for kndex in 0..<sheep.size {
                                let sinkLocation = sheeps[index].coordinates[kndex]
                                
                                board[sinkLocation.row][sinkLocation.col] = .sink
                                sheeps[index].statuses[kndex] = .sink
                            }
                            
                            delegate?.didShearSheep(self)
                            didShearBattleSheep = true
                            print("I'm sinking!!!")
                        }
                        stopCheckingSheep = true
                        break
                    }
                }
                
                if stopCheckingSheep {
                    break
                }
            }
            
//            print(Responses.hit.rawValue + (didShearBattleSheep ? " \(Responses.shearedBattleSheep.rawValue)" : ""))
//            print("BattleSheep remaining: \(sheepRemaining)/\(sheeps.count)")

            if didShearBattleSheep && isGameOver {
                print(Responses.gameOver.rawValue)
                print("Accuracy: \(totalHits)/\(totalAttacks) = \(String(format: "%.1f", Double(totalHits)/Double(totalAttacks) * 100))%")
            }
        }
        
//        print(self)
        
        return board[location.row][location.col]
    }
    
    
    // MARK: - Computer AI
    
    //Computer moves
    mutating func cpuMove() {
        
        if cpuFoundSheepInitialLocation == nil { //start of a new search
            print("cpuFoundSheepInitialLocation = nil")
            cpuMoveHelper()
        }
        else { //found a sheep, start looking at surrounding coordinates
            var move = Coordinates(row: cpuLastMove.location.row + cpuFoundSheepDirection.ud,
                                   col: cpuLastMove.location.col + cpuFoundSheepDirection.lr)
            //If reach end of bounds, keep cycling until you're back in bounds of the board.
            while move == nil {
                cpuChangeDirections()
                move = Coordinates(row: cpuLastMove.location.row + cpuFoundSheepDirection.ud,
                                   col: cpuLastMove.location.col + cpuFoundSheepDirection.lr)
            }
            
            cpuNextMove = (move!, board[move!.row][move!.col])
            
            if cpuNextMove.status == .sheep {
                cpuLastMove = cpuNextMove
                fire(at: cpuNextMove.location)
                print("if status = .sheep")
                print("   last/next: \(cpuLastMove!)")
//                if cpuNextMove.status == .sink {
//                    cpuFoundSheepInitialLocation = nil
//                    print("sank! restarting...")
//
//                    if isGameOver {
//                        cpuLastMove = nil
//                        cpuFoundSheepDirection = (1, 0)
//                        print("gave over check")
//                    }
//                }
            }
            else if cpuNextMove.status == .blank { //dead end, start at initial sheep found position
                cpuLastMove = (cpuFoundSheepInitialLocation!, .sheep)
                fire(at: cpuNextMove.location)
                cpuChangeDirections()
                print("if status = .blank")
                print("   last: \(cpuLastMove!)")
                print("   next: \(cpuNextMove!)")
            }
            else { //.hit, .miss, .sink
                var infiniteBreak = 0
                
                while cpuNextMove.status == .hit || cpuNextMove.status == .miss || cpuNextMove.status == .sink {
                    
                    var move = Coordinates(row: cpuLastMove.location.row + cpuFoundSheepDirection.ud,
                                           col: cpuLastMove.location.col + cpuFoundSheepDirection.lr)
                    //If reach end of bounds, keep cycling until you're back in bounds of the board.
                    while move == nil {
                        cpuChangeDirections()
                        move = Coordinates(row: cpuLastMove.location.row + cpuFoundSheepDirection.ud,
                                           col: cpuLastMove.location.col + cpuFoundSheepDirection.lr)
                    }
                    
                    cpuLastMove = (move!, board[move!.row][move!.col])

                    infiniteBreak += 1
                    if infiniteBreak > 4 {
                        cpuFoundSheepInitialLocation = nil
                        cpuMoveHelper()
                        break
                    }
                }
                
            }//end else .hit, miss, .sink
        }//end else found sheep
    }//end cpuMove()
    
    
    private mutating func cpuMoveHelper() {
        while true { //loop until you hit a .blank or .sheep
            guard let move = Coordinates(row: getRandomSpace(), col: getRandomSpace()) else {
                fatalError("Something went wrong!")
            }
            
            cpuNextMove = (move, board[move.row][move.col])
            
            if cpuNextMove.status == .blank || cpuNextMove.status == .sheep {
                if cpuNextMove.status == .sheep {
                    cpuFoundSheepInitialLocation = cpuNextMove.location
                }

                cpuLastMove = cpuNextMove
                fire(at: cpuNextMove.location)
                print("New search (random)")
                print("   last/next: \(cpuLastMove!)")
                break
            }
        }
    }
    
    
    // MARK: - Helper methods
    
    private mutating func resetBoard() {
        board = Array(repeating: Array(repeating: .blank, count: BattleSheep.boardSize), count: BattleSheep.boardSize)
        sheeps = [Sheep(size: 2), Sheep(size: 3), Sheep(size: 3), Sheep(size: 4), Sheep(size: 5)]
        totalAttacks = 0
        totalHits = 0
    }
    
    private mutating func placeAllSheep() {
        for index in 0..<sheeps.count {
            while true {
                let attemptToPlaceSheep = try? sheeps[index].placeSheep(on: &board,
                                                                        at: Coordinates(row: getRandomSpace(), col: getRandomSpace())!)
                if attemptToPlaceSheep != nil {
                    break
                }
            }
        }
    }
    
    private mutating func cpuChangeDirections() {
        //cpuFoundSheepDirection(lr: Int, ud: Int)
        switch cpuFoundSheepDirection {
        case (1, 0):
            cpuFoundSheepDirection = (-1, 0) //change left
        case (-1, 0):
            cpuFoundSheepDirection = (0, -1) //change up
        case (0, -1):
            cpuFoundSheepDirection = (0, 1) //change down
        case (0, 1):
            cpuFoundSheepDirection = (1, 0) //change right
        default:
            print("cpuFoundSheepDirection invalid value.")
        }
    }

}
