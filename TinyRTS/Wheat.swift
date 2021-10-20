//
//  Wheat.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 19/09/2021.
//

import SpriteKit
import GameplayKit

class Wheat: SKSpriteNode {
    
    var amountOfWheat: Int = 10
    
    init() {
        super.init(texture: SKTexture(imageNamed: "empty", filter: .nearest), color: UIColor.red, size: CGSize(width: 32, height: 32))
        self.zPosition = 3
        self.name = "Wheat"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
