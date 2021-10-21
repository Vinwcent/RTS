//
//  Farm.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 20/08/2021.
//

import SpriteKit
import GameplayKit

class Farm: Buildings {
    
    
    
    init(race: Race, index: PlayerType) {
        let texture = SKTexture(imageNamed: "construction", filter: .nearest)
        super.init(texture: texture,size: CGSize(width: 32, height: 32), race: race, index: index)
        self.buildingType = .farm
        self.finishTexture = SKTexture(imageNamed: "\(race)"+"Farm1", filter: .nearest)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
