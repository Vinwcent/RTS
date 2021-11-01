//
//  Forest.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 17/08/2021.
//

import SpriteKit
import GameplayKit

class Forest: SKSpriteNode {
    
    var amountOfWood: Int = 100
    
    init() {
        super.init(texture: SKTexture(imageNamed: "empty", filter: .nearest), color: UIColor.red, size: CGSize(width: 32, height: 32))
        self.zPosition = 3
        self.name = "Forest"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
