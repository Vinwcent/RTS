//
//  Mine.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 19/08/2021.
//

import SpriteKit
import GameplayKit

class Mine: SKSpriteNode {
    
    var amountOfGold: Int = 1000
    var miners: Int = 0 {
        didSet {
            if miners > 0 {
                self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "goldMine1", filter: .nearest),SKTexture(imageNamed: "goldMine2", filter: .nearest),SKTexture(imageNamed: "goldMine3", filter: .nearest),SKTexture(imageNamed: "goldMine4", filter: .nearest)], timePerFrame: 0.2)))
            } else {
                self.removeAllActions()
            }
        }
    }
    
    init() {
        super.init(texture: SKTexture(imageNamed: "goldMine1", filter: .nearest), color: UIColor.red, size: CGSize(width: 64, height: 64))
        self.zPosition = 3
        self.anchorPoint = CGPoint(x: 16/size.width, y: 16/size.height)
        self.name = "Mine"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
