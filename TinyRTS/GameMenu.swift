//
//  GameMenu.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 15/08/2021.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    enum Error {
        case space, ressources, build
    }
    
    func setupTheGameMenu() {
        guard let scene = self.scene as? GameScene else {return}
        menuNode = Menu(race: scene.localPlayer!.race )
        self.addChild(menuNode)
        menuNode.xScale = 1
        menuNode.yScale = 1
        menuNode.position = CGPoint(x: self.size.width/2, y: self.size.height - (self.view?.safeAreaInsets.top)! - self.gui.size.height - menuNode.size.height/2)
        pixelArtMenu()
        
        self.addChild(unitSelection)
        unitSelection.position = CGPoint(x: 0, y: self.size.height/2)
        
        self.addChild(gui)
        gui.position = CGPoint(x: self.size.width/2 , y: self.size.height - gui.size.height/2 - (self.view?.safeAreaInsets.top)!)
        
        self.addChild(descriptionNode)
        descriptionNode.position = CGPoint(x: self.size.width/2, y: descriptionNode.size.height/2 + (self.view?.safeAreaInsets.bottom)!)
    }
    
    private func pixelArtMenu() {
        let tileSet = menuNode.menuLayer.tileSet
        for tileGroup in tileSet.tileGroups {
            for tileRule in tileGroup.rules {
                for tileDefinition in tileRule.tileDefinitions {
                    tileDefinition.size = CGSize(width: 40, height: 40)
                    for texture in tileDefinition.textures {
                        texture.filteringMode = .nearest
                    }
                }
            }
        }
    }
    
    func setupGlass() {
        glass = SKSpriteNode(texture: SKTexture(imageNamed: "glass", filter: .nearest), color: UIColor.white, size: CGSize(width: 28, height: 42))
        glass.zPosition = 5
        glass.alpha = 0.3
        self.addChild(glass)
        glass.position = CGPoint(x: self.size.width - glass.size.width/2 - 10 , y: self.size.height/2)
        
    }
    
    func showError(type: Error) {
        var text: String
        switch type {
        case .ressources:
            text = "Pas assez de ressources"
        case .space:
            text = "Emplacement indisponible"
        case .build:
            text = "Batîments inaccessible"
        }
        let errorNode = SKNode()
        let errorMessage = SKLabelNode(fontNamed: "qwerty-two")
        errorMessage.fontSize = self.size.width*64/1024
        errorMessage.text = text
        errorMessage.fontColor = UIColor.white
        errorMessage.zPosition = 10
        errorNode.addChild(errorMessage)
        errorNode.setScale(0)
        self.addChild(errorNode)
        errorNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        errorNode.run(SKAction.sequence([SKAction.scale(to: 1, duration: 0.3),SKAction.wait(forDuration: 0.8),SKAction.scale(to: 0, duration: 0.3),SKAction.run {
            errorNode.removeFromParent()
        }]))
    }
    
    
}
