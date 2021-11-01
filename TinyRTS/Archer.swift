//
//  Archer.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 30/09/2021.
//

import SpriteKit
import GameplayKit

class Archer: Units {
    
    override init(race: Race, positionInMap: [Int], index: PlayerType) {
        super.init(race: race,positionInMap: positionInMap, index: index)
        self.unitType = .archer
        self.celerity = 48
        self.life = 350
        self.maxLife = 350
        self.attack = 25
        switch self.race {
        case .orc:
            self.unitName = "archer"
        case .human:
            self.unitName = "archer"
        }
        self.action = .idle
        self.range = 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
