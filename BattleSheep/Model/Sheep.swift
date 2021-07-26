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
    var coordinates: [Coordinates] = []
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

    
    // MARK: - Methods
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
                             at location: Coordinates,
                             placement: Placement = .allCases.randomElement()!) throws -> Bool? {
        
        let placementLR = placement == .left || placement == .right
        let placementUD = placement == .up || placement == .down
        
        //Placement checks
        guard (placementLR && location.row + size < board.count) || (placementUD && location.col + size < board.count) else {
            throw PlacementError.notEnoughRoom
        }
        
        for space in 0..<size {
            guard (placementLR && board[location.row + space][location.col] == .blank) || (placementUD && board[location.row][location.col + space] == .blank) else {
                throw PlacementError.noBlankSpaces
            }
        }
        
        //SUCCESS!
        self.placement = placement

        for space in 0..<size {
            let newLocation = Coordinates(row: location.row + (placementLR ? space : 0),
                                          col: location.col + (placementLR ? 0 : space))!
            
            board[newLocation.row][newLocation.col] = .sheep
            coordinates.append(newLocation)
        }

        return true
    }
}
