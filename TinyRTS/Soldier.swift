//
//  Grunt.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 24/08/2021.
//

import SpriteKit
import GameplayKit

class Soldier: Units {
    
    override init(race: Race, positionInMap: [Int], index: PlayerType) {
        super.init(race: race,positionInMap: positionInMap, index: index)
        self.unitType = .soldier
        self.celerity = 64
        self.maxLife = 20
        self.life = 20
        switch self.race {
        case .orc:
            self.unitName = "grunt"
        case .human:
            self.unitName = "soldier"
        }
        self.action = .idle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
