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
        switch self.race {
        case .orc:
            self.unitName = "grunt"
        case .human:
            self.unitName = "soldier"
        }
        self.action = .idle
        
        giveStats()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func giveStats() {
        if self.race == .human {
            self.celerity = 48
            self.maxLife = 420
            self.life = 420
            self.attack = 17
        } else {
            self.celerity = 48
            self.maxLife = 700
            self.life = 700
            self.attack = 20
        }
    }
    
    
}
