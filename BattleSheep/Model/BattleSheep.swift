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


// MARK: - BattleSheep
struct BattleSheep: CustomStringConvertible {
    
    //Properties
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
    
    
    //Methods
    init() {
        newGame()
    }
    
    mutating func newGame() {
        resetBoard()
        placeAllSheep()
    }
    
    mutating func fire(at coordinates: (row: Int, col: Int)) {
        guard let letterTemp = UnicodeScalar(coordinates.row + 97) else {
            print(Responses.invalidInput.rawValue)
            return
        }
        
        let letter = Character(letterTemp)
        let number = coordinates.col + 1
        
        fire(at: "\(letter)\(number)")
    }
    
    mutating func fire(at location: String) {
        guard !isGameOver else {
            print(Responses.gameOver.rawValue)
            return
        }
        
        print("\n")
        
        guard let rowTemp = Unicode.Scalar(location.prefix(1).lowercased()),
              let colTemp = Int(String(location.suffix(location.count - 1))) else {
            print(Responses.invalidInput.rawValue)
            return
        }
        
        let row = Int((rowTemp as UnicodeScalar).value) - 97
        let col = colTemp - 1

        guard row < BattleSheep.boardSize && col >= 0 && col < BattleSheep.boardSize else {
            print(Responses.invalidInput.rawValue)
            return
        }

        
        //SUCCESS!
        switch board[row][col] {
        case .blank:
            board[row][col] = .miss
            totalAttacks += 1
            print(Responses.miss.rawValue)
        case .miss, .hit, .sink:
            print(Responses.alreadyAttacked.rawValue)
        case .sheep:
            board[row][col] = .hit
            totalHits += 1
            totalAttacks += 1

            var stopCheckingSheep = false
            var didShearBattleSheep = false
            
            for (index, sheep) in sheeps.enumerated() {
                for (jndex, coordinates) in sheep.coordinates.enumerated() {
                    if (row, col) == coordinates {
                        sheeps[index].statuses[jndex] = .hit
                        
                        if sheeps[index].isShorn {
                            
                            //This feels inefficient but seems the only way to go???
                            for kndex in 0..<sheep.size {
                                sheeps[index].statuses[kndex] = .sink
                                board[sheeps[index].coordinates[kndex].row][sheeps[index].coordinates[kndex].col] = .sink
                            }
                            
                            delegate?.didShearSheep(self)
                            didShearBattleSheep = true
                        }
                        stopCheckingSheep = true
                        break
                    }
                }
                
                if stopCheckingSheep {
                    break
                }
            }
            
            print(Responses.hit.rawValue + (didShearBattleSheep ? " \(Responses.shearedBattleSheep.rawValue)" : ""))
            print("BattleSheep remaining: \(sheepRemaining)/\(sheeps.count)")

            if didShearBattleSheep && isGameOver {
                print(Responses.gameOver.rawValue)
                print("Accuracy: \(totalHits)/\(totalAttacks) = \(String(format: "%.1f", Double(totalHits)/Double(totalAttacks) * 100))%")
            }
        }
        
        print(self)
    }
    
    //Helper methods
    private mutating func resetBoard() {
        board = Array(repeating: Array(repeating: .blank, count: BattleSheep.boardSize), count: BattleSheep.boardSize)
        sheeps = [Sheep(size: 2), Sheep(size: 3), Sheep(size: 3), Sheep(size: 4), Sheep(size: 5)]
        totalAttacks = 0
        totalHits = 0
    }
    
    private mutating func placeAllSheep() {
        for index in 0..<sheeps.count {
            while true {
                print("trying... \(sheeps[index].size)")
                let rowRand = Int.random(in: 0..<BattleSheep.boardSize)
                let colRand = Int.random(in: 0..<BattleSheep.boardSize)
                let attemptToPlaceSheep = try? sheeps[index].placeSheep(on: &board, at: (row: rowRand, col: colRand))
                
                if attemptToPlaceSheep != nil {
                    break
                }
            }
        }
        
        print("Placed sheep.")
    }
}
