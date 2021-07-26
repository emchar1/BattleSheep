//
//  Coordinates.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/16/21.
//

import Foundation

struct Coordinates: Equatable {
    let row: Int
    let col: Int
    var a1: String {
        guard let letterTemp = UnicodeScalar(row + 97) else {
            fatalError("This shouldn't happen. Something went wrong.")
        }
        
        let letter = Character(letterTemp)
        let number = col + 1
        
        return "\(letter)\(number)"
    }
    
    
    // MARK: - Methods
    init?(row: Int, col: Int) {
        guard row >= 0 && row < BattleSheep.boardSize && col >= 0 && col < BattleSheep.boardSize else {
            print(PlacementError.notEnoughRoom)
            return nil
        }
        
        self.row = row
        self.col = col
    }

    init?(at a1: String) {
        guard let rowTemp = Unicode.Scalar(a1.prefix(1).lowercased()),
              let colTemp = Int(String(a1.suffix(a1.count - 1))) else {
            print(Responses.invalidInput.rawValue)
            return nil
        }
                
//        let location = Coordinates(row: Int((rowTemp as UnicodeScalar).value) - 97, col: colTemp - 1)

        guard let location = Coordinates(row: Int((rowTemp as UnicodeScalar).value) - 97, col: colTemp - 1),
              location.row < BattleSheep.boardSize && location.col >= 0 && location.col < BattleSheep.boardSize else {
            print(Responses.invalidInput.rawValue)
            return nil
        }
        
        self.row = location.row
        self.col = location.col
    }
        
    static func ==(lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
}
