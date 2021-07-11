//
//  Sheep.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/9/21.
//

import Foundation

enum Placement: CaseIterable {
    case up, down, left, right
}

enum PlacementError: Error {
    case notEnoughRoom, noBlankSpaces
}

enum BodyPart {
    case head, tail, body
}


// MARK: - Sheep
struct Sheep {
    
    //Properties
    let size: Int
    var coordinates: [(row: Int, col: Int)] = []
    var bodyParts: [BodyPart] = []
    var statuses: [BoardStatus]
    var placement: Placement?

    var isShorn: Bool {
        for space in statuses {
            if space != .hit && space != .sink {
                return false
            }
        }
        
        return true
    }

    
    //Methods
    init(size: Int) {
        self.size = size
        statuses = Array(repeating: .sheep, count: size)
        
        for index in 0..<size {
            switch index {
            case 0:
                bodyParts.append(.head)
            case size - 1:
                bodyParts.append(.tail)
            default:
                bodyParts.append(.body)
            }
        }
    }
    
    mutating func placeSheep(on board: inout [[BoardStatus]],
                             at location: (row: Int, col: Int),
                             placement: Placement = .allCases.randomElement()!) throws -> Bool? {
        
        //Placement checks
        guard ((placement == .left || placement == .right) && location.row + size < board.count) ||
                ((placement == .up || placement == .down) && location.col + size < board.count) else {
            throw PlacementError.notEnoughRoom
        }
        
        for space in 0..<size {
            guard ((placement == .left || placement == .right) && board[location.row + space][location.col] == .blank) ||
                    ((placement == .up || placement == .down) && board[location.row][location.col + space] == .blank) else {
                throw PlacementError.noBlankSpaces
            }
        }
        
        //SUCCESS!
        self.placement = placement

        for space in 0..<size {
            let row = location.row + ((placement == .left || placement == .right) ? space : 0)
            let col = location.col + ((placement == .left || placement == .right) ? 0 : space)
            board[row][col] = .sheep
            coordinates.append((row: row, col: col))
        }

        return true
    }
}
