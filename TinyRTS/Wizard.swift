//
//  Wizard.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 06/10/2021.
//

import SpriteKit
import GameplayKit

class Wizard: Units {
    
    override init(race: Race, positionInMap: [Int], index: PlayerType) {
        super.init(race: race,positionInMap: positionInMap, index: index)
        self.unitType = .wizard
        self.celerity = 48
        self.life = 20
        self.maxLife = 20
        switch self.race {
        case .orc:
            self.unitName = "wizard"
        case .human:
            self.unitName = "wizard"
        }
        self.action = .idle
        self.range = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
