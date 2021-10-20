//
//  Player.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 22/08/2021.
//

import SpriteKit
import GameplayKit

struct Player: Codable {
    
    
    var race: Race = .orc
    var displayName: String
    var index: PlayerType = .one
    
    init(displayName: String) {
        self.displayName = displayName
    }
    
}

enum PlayerType: String, Codable, CaseIterable {
    case one, two
}

extension PlayerType {
    func giveIndex(index: PlayerType) -> Int {
        switch index {
        case .one:
            return 0
        case .two:
            return 1
        }
    }
}

enum Race: String, Codable, CaseIterable {
    case human, orc
}


