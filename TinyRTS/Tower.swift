//
//  Tower.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 07/10/2021.
//

import SpriteKit
import GameplayKit

class Tower: Buildings {
    
    var attack: Int = 1
    
    init(race: Race, index: PlayerType) {
        let texture = SKTexture(imageNamed: "construction", filter: .nearest)
        super.init(texture: texture,size: CGSize(width: 32, height: 64),race: race,index: index)
        self.buildingType = .tower
        self.finishTexture = SKTexture(imageNamed: "\(race)"+"Tower", filter: .nearest)
        
        giveStats()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func giveStats() {
        if self.race == .human {
            self.attack = 25
            self.maxLife = 500
            self.life = 500
            self.builtPercentageIncrease = 3
        } else {
            self.attack = 20
            self.maxLife = 500
            self.life = 500
            self.builtPercentageIncrease = 3
        }
    }
    
    
    
    // MARK: - ATTACK SYSTEM
    
    func searchEnemies() {
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1.5),SKAction.run {
            self.checkIfEnemies(radius: 4)
        }])))
    }
    
    func checkIfUnits(row: Int, column: Int) -> Units? {
        guard let scene = self.scene as? GameScene else {return nil}
        let nodesTouched = scene.map.nodes(at: (scene.mapLayer?.centerOfTile(atColumn: column, row: row))!)
        var nodeTouched = SKNode()
        for i in 0..<nodesTouched.count {
            if nodesTouched[i].zPosition == 1 {
                nodeTouched = nodesTouched[i]
            }
        }
        if let unit = nodeTouched as? Units {
            if unit.index != self.index {
                return unit
            }
        }
        return nil
    }
    
    
    func checkIfEnemies(radius: Int) {
        for k in 1...radius {
            for i in -k...k {
                if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]-k+abs(i)), unit.index != self.index {
                    self.removeAllActions()
                    attack(unit: unit)
                    return
                }
                if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]+k-abs(i)), unit.index != self.index {
                    self.removeAllActions()
                    attack(unit: unit)
                    return
                }
            }
        }
    }
    
    private func attack(unit: Units) {
        guard let scene = self.scene as? GameScene else {return}
        guard unit.parent == scene.map else {
            self.searchEnemies()
            return
        }
        let columnDifference = abs(self.positionInMap[0] - unit.positionInMap[0])
        let rowDifference = abs(self.positionInMap[1] - unit.positionInMap[1])
        if columnDifference+rowDifference <= 4 {
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run {
                unit.life -= 1
                self.removeAllActions()
                self.attack(unit: unit)
            }]))
        } else {
            self.searchEnemies()
        }
    }
    
    
    
    
    
    
    
}
