//
//  Supply.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 23/09/2021.
//

import SpriteKit
import GameplayKit

class Supply: Buildings {
    
    init(race: Race, index: PlayerType) {
        let texture = SKTexture(imageNamed: "construction", filter: .nearest)
        super.init(texture: texture,size: CGSize(width: 32, height: 32),race: race,index: index)
        self.buildingType = .supply
        self.finishTexture = SKTexture(imageNamed: "\(race)"+"Supply", filter: .nearest)
        
        giveStats()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func giveStats() {
        if self.race == .human {
            self.maxLife = 500
            self.life = 500
            self.builtPercentageIncrease = 4
        } else {
            self.maxLife = 500
            self.life = 500
            self.builtPercentageIncrease = 4
        }
    }
    
}
