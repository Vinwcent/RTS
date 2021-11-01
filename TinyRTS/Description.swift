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
            guard let scene = self.scene as? GameScene else {return}
            let race:Race = scene.localPlayer!.race
            
            switch state {
            case .none:
                self.isHidden = true
            case .peasant:
                self.isHidden = false
                self.descriptionLabel.text = "Paysan"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanPeasant[0])"
                    self.goldLabel.text = "\(Price.humanPeasant[1])"
                    self.wheatLabel.text = "\(Price.humanPeasant[2])"
                    self.unitsLabel.text = "\(Price.humanPeasant[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcPeasant[0])"
                    self.goldLabel.text = "\(Price.orcPeasant[1])"
                    self.wheatLabel.text = "\(Price.orcPeasant[2])"
                    self.unitsLabel.text = "\(Price.orcPeasant[3])"
                }
            case .soldier:
                self.isHidden = false
                self.descriptionLabel.text = "Soldat"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanSoldier[0])"
                    self.goldLabel.text = "\(Price.humanSoldier[1])"
                    self.wheatLabel.text = "\(Price.humanSoldier[2])"
                    self.unitsLabel.text = "\(Price.humanSoldier[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcSoldier[0])"
                    self.goldLabel.text = "\(Price.orcSoldier[1])"
                    self.wheatLabel.text = "\(Price.orcSoldier[2])"
                    self.unitsLabel.text = "\(Price.orcSoldier[3])"
                }
            case .ambassador:
                self.isHidden = false
                self.descriptionLabel.text = "Voleur"
                self.woodLabel.text = "\(Price.ambassador[0])"
                self.goldLabel.text = "\(Price.ambassador[1])"
                self.wheatLabel.text = "\(Price.ambassador[2])"
                self.unitsLabel.text = "\(Price.ambassador[3])"
            case .wolf:
                self.isHidden = false
                self.descriptionLabel.text = "Loup"
                self.woodLabel.text = "\(Price.wolf[0])"
                self.goldLabel.text = "\(Price.wolf[1])"
                self.wheatLabel.text = "\(Price.wolf[2])"
                self.unitsLabel.text = "\(Price.wolf[3])"
            case .wizard:
                self.isHidden = false
                self.descriptionLabel.text = "Sorcier"
                self.woodLabel.text = "\(Price.wizard[0])"
                self.goldLabel.text = "\(Price.wizard[1])"
                self.wheatLabel.text = "\(Price.wizard[2])"
                self.unitsLabel.text = "\(Price.wizard[3])"
            case .archer:
                self.isHidden = false
                self.descriptionLabel.text = "Archer"
                self.woodLabel.text = "\(Price.archer[0])"
                self.goldLabel.text = "\(Price.archer[1])"
                self.wheatLabel.text = "\(Price.archer[2])"
                self.unitsLabel.text = "\(Price.archer[3])"
            case .base:
                self.isHidden = false
                self.descriptionLabel.text = "Base"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanBase[0])"
                    self.goldLabel.text = "\(Price.humanBase[1])"
                    self.wheatLabel.text = "\(Price.humanBase[2])"
                    self.unitsLabel.text = "\(Price.humanBase[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcBase[0])"
                    self.goldLabel.text = "\(Price.orcBase[1])"
                    self.wheatLabel.text = "\(Price.orcBase[2])"
                    self.unitsLabel.text = "\(Price.orcBase[3])"
                }
            case .farm:
                self.isHidden = false
                self.descriptionLabel.text = "Ferme"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanFarm[0])"
                    self.goldLabel.text = "\(Price.humanFarm[1])"
                    self.wheatLabel.text = "\(Price.humanFarm[2])"
                    self.unitsLabel.text = "\(Price.humanFarm[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcFarm[0])"
                    self.goldLabel.text = "\(Price.orcFarm[1])"
                    self.wheatLabel.text = "\(Price.orcFarm[2])"
                    self.unitsLabel.text = "\(Price.orcFarm[3])"
                }
            case.barrack:
                self.isHidden = false
                self.descriptionLabel.text = "Caserne"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanBarrack[0])"
                    self.goldLabel.text = "\(Price.humanBarrack[1])"
                    self.wheatLabel.text = "\(Price.humanBarrack[2])"
                    self.unitsLabel.text = "\(Price.humanBarrack[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcBarrack[0])"
                    self.goldLabel.text = "\(Price.orcBarrack[1])"
                    self.wheatLabel.text = "\(Price.orcBarrack[2])"
                    self.unitsLabel.text = "\(Price.orcBarrack[3])"
                }
            case .windmill:
                self.isHidden = false
                self.descriptionLabel.text = "Moulin"
                self.woodLabel.text = "\(Price.windmill[0])"
                self.goldLabel.text = "\(Price.windmill[1])"
                self.wheatLabel.text = "\(Price.windmill[2])"
                self.unitsLabel.text = "\(Price.windmill[3])"
            case .supply:
                self.isHidden = false
                self.descriptionLabel.text = "Tente"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanSupply[0])"
                    self.goldLabel.text = "\(Price.humanSupply[1])"
                    self.wheatLabel.text = "\(Price.humanSupply[2])"
                    self.unitsLabel.text = "\(Price.humanSupply[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcSupply[0])"
                    self.goldLabel.text = "\(Price.orcSupply[1])"
                    self.wheatLabel.text = "\(Price.orcSupply[2])"
                    self.unitsLabel.text = "\(Price.orcSupply[3])"
                }
            case .tower:
                self.isHidden = false
                self.descriptionLabel.text = "Tour"
                if race == .human {
                    self.woodLabel.text = "\(Price.humanTower[0])"
                    self.goldLabel.text = "\(Price.humanTower[1])"
                    self.wheatLabel.text = "\(Price.humanTower[2])"
                    self.unitsLabel.text = "\(Price.humanTower[3])"
                } else {
                    self.woodLabel.text = "\(Price.orcTower[0])"
                    self.goldLabel.text = "\(Price.orcTower[1])"
                    self.wheatLabel.text = "\(Price.orcTower[2])"
                    self.unitsLabel.text = "\(Price.orcTower[3])"
                }
            
            }
        }
    }
    
    enum State: String {
        case none, peasant, soldier, ambassador, wolf, wizard, archer, base = "base", farm = "farm", barrack = "barrack", windmill = "windmill", supply = "supply", tower = "tower"
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
        woodSprite.position = CGPoint(x: 25, y: -20)
        goldSprite.zPosition = 6
        goldSprite.position = CGPoint(x: -50, y: -20)
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
