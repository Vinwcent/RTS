//
//  Ambassador.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 25/09/2021.
//

import SpriteKit
import GameplayKit

class Ambassador: Units {
    
    override init(race: Race, positionInMap: [Int], index: PlayerType) {
        super.init(race: race,positionInMap: positionInMap, index: index)
        self.unitType = .ambassador
        self.celerity = 64
        self.life = 20
        self.maxLife = 20
        switch self.race {
        case .orc:
            self.unitName = "ambassador"
        case .human:
            self.unitName = "ambassador"
        }
        self.action = .idle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
