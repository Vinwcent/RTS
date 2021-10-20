//
//  Windmill.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 16/09/2021.
//

import Foundation

import SpriteKit
import GameplayKit

class Windmill: Buildings {
    
    init(race: Race, index: PlayerType) {
        let texture = SKTexture(imageNamed: "construction", filter: .nearest)
        super.init(texture: texture,size: CGSize(width: 32, height: 32),race: race,index: index)
        self.buildingType = .windmill
        self.finishTexture = SKTexture(imageNamed: "windmill1", filter: .nearest)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnWheat() {
        guard let scene = self.scene as? GameScene else {return}
        let column = self.positionInMap[0]
        let row = self.positionInMap[1]
        for i in -2...2 {
            for j in -2...2 {
                let tile = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column+j),Int32(row+i)))
                guard tile != nil else {continue}
                scene.mapBackground?.setTileGroup(scene.mapBackground?.tileSet.tileGroups.first {$0.name == "Wheat"}, forColumn: column+j, row: row+i)
                
                let location = scene.mapLayer?.centerOfTile(atColumn: column+j, row: row+i)
                let wheatNode = Wheat()
                scene.map.addChild(wheatNode)
                wheatNode.position = location!
            }
        }
    }
    
    
    
    
    
}
