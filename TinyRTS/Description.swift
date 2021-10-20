//
//  Description.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 23/09/2021.
//

import SpriteKit
import GameplayKit

class Description: SKSpriteNode {
    
    var descriptionLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    
    var woodLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    var goldLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    var wheatLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    var unitsLabel: SKLabelNode = SKLabelNode(fontNamed: "qwerty-two")
    
    var woodSprite = SKSpriteNode(texture: SKTexture(imageNamed: "wood", filter: .nearest), size: CGSize(width: 25, height: 25))
    var goldSprite = SKSpriteNode(texture: SKTexture(imageNamed: "goldBar", filter: .nearest), size: CGSize(width: 25, height: 25))
    var wheatSprite = SKSpriteNode(texture: SKTexture(imageNamed: "wheatIcon", filter: .nearest), size: CGSize(width: 15, height: 15))
    var unitsSprite = SKSpriteNode(texture: SKTexture(imageNamed: "bag", filter: .nearest), size: CGSize(width: 15, height: 15))
    
    var state: State = .none {
        didSet {
            switch state {
            case .none:
                self.isHidden = true
            case .peasant:
                self.isHidden = false
                self.descriptionLabel.text = "Paysan"
                self.woodLabel.text = "\(Price.orcPeasant[0])"
                self.goldLabel.text = "\(Price.orcPeasant[1])"
                self.wheatLabel.text = "\(Price.orcPeasant[2])"
                self.unitsLabel.text = "\(Price.orcPeasant[3])"
                
            case .base:
                self.isHidden = false
                self.descriptionLabel.text = "Base"
                self.woodLabel.text = "100"
                self.goldLabel.text = "50"
                self.wheatLabel.text = "10"
                
            case .farm:
                self.isHidden = false
                self.descriptionLabel.text = "Ferme"
            case.barrack:
                self.isHidden = false
                self.descriptionLabel.text = "Caserne"
            case .windmill:
                self.isHidden = false
                self.descriptionLabel.text = "Moulin"
            case .supply:
                self.isHidden = false
                self.descriptionLabel.text = "Tente"
            case .tower:
                self.isHidden = false
                self.descriptionLabel.text = "Tour"
            
            }
        }
    }
    
    enum State {
        case none, peasant, base, farm, barrack, windmill, supply, tower
    }
    
    init() {
        super.init(texture: SKTexture(imageNamed: "descriptionMenu", filter: .nearest), color: UIColor.red, size: CGSize(width: 304, height: 148))
        self.zPosition = 6
        
        setupDescription()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDescription() {
        self.descriptionLabel.zPosition = 6
        self.addChild(descriptionLabel)
        self.descriptionLabel.position = CGPoint(x: -100, y: 24)
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.fontSize = 32
        self.descriptionLabel.preferredMaxLayoutWidth = 200
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.horizontalAlignmentMode = .left
        self.descriptionLabel.verticalAlignmentMode = .center
        self.descriptionLabel.fontColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
        
        self.addChild(woodSprite)
        self.addChild(goldSprite)
        self.addChild(wheatSprite)
        self.addChild(unitsSprite)
        
        woodSprite.zPosition = 6
        woodSprite.position = CGPoint(x: -50, y: -20)
        goldSprite.zPosition = 6
        goldSprite.position = CGPoint(x: 25, y: -20)
        wheatSprite.zPosition = 6
        wheatSprite.position = CGPoint(x: 20, y: 20)
        unitsSprite.zPosition = 6
        unitsSprite.position = CGPoint(x: 70, y: 20)
        
        woodSprite.addChild(woodLabel)
        goldSprite.addChild(goldLabel)
        wheatSprite.addChild(wheatLabel)
        unitsSprite.addChild(unitsLabel)
        
        woodLabel.fontColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
        woodLabel.position = CGPoint(x: 25, y: 0)
        woodLabel.fontSize = 25
        woodLabel.horizontalAlignmentMode = .left
        woodLabel.verticalAlignmentMode = .center
        
        goldLabel.fontColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
        goldLabel.position = CGPoint(x: 25, y: 0)
        goldLabel.fontSize = 25
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.verticalAlignmentMode = .center
        
        wheatLabel.fontColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
        wheatLabel.position = CGPoint(x: 15, y: 0)
        wheatLabel.fontSize = 15
        wheatLabel.horizontalAlignmentMode = .left
        wheatLabel.verticalAlignmentMode = .center
        
        unitsLabel.fontColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
        unitsLabel.position = CGPoint(x: 15, y: 0)
        unitsLabel.fontSize = 15
        unitsLabel.horizontalAlignmentMode = .left
        unitsLabel.verticalAlignmentMode = .center
        
        self.isHidden = true
        
    }
    
    
    
    
}
