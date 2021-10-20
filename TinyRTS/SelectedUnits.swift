//
//  SelectedUnits.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 10/10/2021.
//

import SpriteKit
import GameplayKit

class SelectedUnits: SKNode {
    
    var amountSelected: Int = 0
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTheLifeBar(unit: Units) -> SKShapeNode {
        let maxWidth = 44
        let width = unit.life*maxWidth/unit.maxLife
        let rect = CGRect(origin: CGPoint(x: -maxWidth/2, y: -3), size: CGSize(width: width, height: 6))
        let lifeBar = SKShapeNode(rect: rect)
        lifeBar.fillColor = UIColor(red: 150/255, green: 25/255, blue: 21/255, alpha: 1)
        lifeBar.lineWidth = 0
        return lifeBar
    }
    
    
    
    func showNothing() {
        self.removeAllChildren()
    }
    
    func showSelectedUnits(amount: Int) {
        self.removeAllChildren()
        amountSelected = amount
        
        guard let scene = self.scene as? GameScene else {return}
        var counter: Int = 0
        scene.map.enumerateChildNodes(withName: "Units") {
            (node:SKNode, nil) in
            let unit = node as! Units
            if unit.isSelected {
                let selectionSprite = SKSpriteNode(texture: SKTexture(imageNamed: "selectUnitMenu", filter: .nearest), color: UIColor.red, size: CGSize(width: 68, height: 74))
                selectionSprite.zPosition = 5
                self.addChild(selectionSprite)
                let offSet = CGFloat((self.amountSelected-1))*selectionSprite.size.height/2
                selectionSprite.position = CGPoint(x: 10 + selectionSprite.size.width/2, y: offSet - CGFloat(counter)*selectionSprite.size.height)
                
                var texture: SKTexture
                if unit.unitType == .soldier || unit.unitType == .peasant {
                    texture = SKTexture(imageNamed: "\(unit.unitName)" + "Idle1", filter: .nearest)
                } else {
                    texture = SKTexture(imageNamed: "\(unit.unitType)"+"Idle1", filter: .nearest)
                }
                let sprite = SKSpriteNode(texture: texture, color: UIColor.red, size: CGSize(width: 30, height: 30))
                sprite.zPosition = 6
                sprite.position = CGPoint(x: 0, y: 5)
                selectionSprite.addChild(sprite)
                
                let lifeBar = self.createTheLifeBar(unit: unit)
                lifeBar.zPosition = 6
                lifeBar.position = CGPoint(x: 0, y: -28)
                selectionSprite.addChild(lifeBar)
                selectionSprite.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: 0, y: 5, duration: 2),SKAction.moveBy(x: 0, y: -5, duration: 2)])))
                
                counter += 1
            }
        }
    }
    
    
}
