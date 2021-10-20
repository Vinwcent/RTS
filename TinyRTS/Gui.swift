//
//  Gui.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 07/09/2021.
//

import Foundation
import SpriteKit
import GameplayKit
import GameKit

class Gui: SKSpriteNode {
    
    var amountOfWood: Int = 0 {
        didSet {
            woodLabel.text = "\(amountOfWood)"
        }
    }
    var amountOfWheat: Int = 0 {
        didSet {
            wheatLabel.text = "\(amountOfWheat)"
        }
    }
    
    var supplyAmount: Int = 10 {
        didSet {
            unitsLabel.text = "\(amountOfUnits)" + "/" + "\(supplyAmount)"
        }
    }
    var amountOfUnits: Int = 0 {
        didSet {
            unitsLabel.text = "\(amountOfUnits)" + "/" + "\(supplyAmount)"
        }
    }
    var amountOfGold: Int = 0 {
        didSet {
            goldLabel.text = "\(amountOfGold)"
        }
    }
    
    var woodLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    var goldLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    var wheatLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    var unitsLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    
    
    init() {
        super.init(texture: SKTexture(imageNamed: "gui", filter: .nearest), color: UIColor.white, size: CGSize(width: 338, height: 82))
        self.zPosition = 5
        setupGui()
    }
    
    func setupGui() {
        let woodSprite = SKSpriteNode(texture: SKTexture(imageNamed: "wood", filter: .nearest), size: CGSize(width: 28, height: 28))
        woodSprite.addChild(woodLabel)
        woodSprite.zPosition = 6
        woodLabel.fontColor = UIColor(red: 0.132, green: 0.132, blue: 0.132, alpha: 1)
        woodLabel.position = CGPoint(x: 35, y: 0)
        woodLabel.fontSize = 18
        woodLabel.verticalAlignmentMode = .center
        amountOfWood = 1000
        self.addChild(woodSprite)
        woodSprite.position = CGPoint(x: -120, y: 0)
        
        let goldSprite = SKSpriteNode(texture: SKTexture(imageNamed: "goldBar", filter: .nearest), size: CGSize(width: 28, height: 28))
        goldSprite.addChild(goldLabel)
        goldSprite.zPosition = 6
        goldLabel.fontColor = UIColor.black
        goldLabel.position = CGPoint(x: 35, y: 0)
        goldLabel.fontSize = 18
        goldLabel.verticalAlignmentMode = .center
        amountOfGold = 1000
        self.addChild(goldSprite)
        goldSprite.position = CGPoint(x: -50, y: 0)
        
        let wheatSprite = SKSpriteNode(texture: SKTexture(imageNamed: "wheatIcon", filter: .nearest), size: CGSize(width: 28, height: 28))
        wheatSprite.addChild(wheatLabel)
        wheatSprite.zPosition = 6
        wheatLabel.fontColor = UIColor.black
        wheatLabel.position = CGPoint(x: 35, y: 0)
        wheatLabel.fontSize = 18
        wheatLabel.verticalAlignmentMode = .center
        amountOfWheat = 0
        self.addChild(wheatSprite)
        wheatSprite.position = CGPoint(x: 20, y: 0)
        
        let unitsSprite = SKSpriteNode(texture: SKTexture(imageNamed: "bag", filter: .nearest), size: CGSize(width: 28, height: 28))
        unitsSprite.addChild(unitsLabel)
        unitsSprite.zPosition = 6
        unitsLabel.fontColor = UIColor.black
        unitsLabel.position = CGPoint(x: 35, y: 0)
        unitsLabel.fontSize = 18
        unitsLabel.verticalAlignmentMode = .center
        unitsLabel.numberOfLines = 0
        unitsLabel.preferredMaxLayoutWidth = 48
        amountOfUnits = 0
        self.addChild(unitsSprite)
        unitsSprite.position = CGPoint(x: 90, y: 0)
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
