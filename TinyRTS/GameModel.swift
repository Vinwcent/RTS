//
//  GameModel.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 26/08/2021.
//

import Foundation
import UIKit
import SpriteKit
import GameKit

struct GameModel: Codable {
    
    var players: [Player] = []
    
    // Player1 Sprites
    var buildingPositionArray: [CGPoint] = []
    var buildingTypeArray: [Buildings.BuildingType] = []
    var builtPercentageArray: [Int] = []
    
    var positionArray: [CGPoint] = []
    var unitTypeArray: [Units.UnitType] = []
    var actionArray: [Units.Action] = []
    var directionArray: [Units.Direction] = []
    var nextPositionInMapArray: [[Int]] = []
    var positionInMapArray: [[Int]] = []
    
    var enemyLifeArray: [Int] = []
    
    // Player2 Sprites
    var buildingPositionArray2: [CGPoint] = []
    var buildingTypeArray2: [Buildings.BuildingType] = []
    var builtPercentageArray2: [Int] = []
    
    var positionArray2: [CGPoint] = []
    var unitTypeArray2: [Units.UnitType] = []
    var actionArray2: [Units.Action] = []
    var directionArray2: [Units.Direction] = []
    var nextPositionInMapArray2: [[Int]] = []
    var positionInMapArray2: [[Int]] = []
    
    var enemyLifeArray2: [Int] = []
}

extension GameModel {
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func decode(data: Data) -> GameModel? {
        return try? JSONDecoder().decode(GameModel.self, from: data)
    }
}
