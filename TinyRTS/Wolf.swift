//
//  Wolf.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 25/09/2021.
//

import SpriteKit
import GameplayKit

class Wolf: Units {
    
    override init(race: Race, positionInMap: [Int], index: PlayerType) {
        super.init(race: race,positionInMap: positionInMap, index: index)
        self.unitType = .wolf
        self.celerity = 80
        self.life = 350
        self.maxLife = 350
        self.attack = 24
        switch self.race {
        case .orc:
            self.unitName = "wolf"
        case .human:
            self.unitName = "wolf"
        }
        self.action = .idle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
