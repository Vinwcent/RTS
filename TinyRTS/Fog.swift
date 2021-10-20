//
//  Fog.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 12/10/2021.
//

import SpriteKit
import GameKit

class Fog: SKNode {
    
    var fogLayer: SKTileMapNode
    
    var visibleTiles: [[Int]] = []
    var viewers: [Int] = []
    
    override init() {
        let tileSet = SKTileSet(named: "MapTileSet")
        let tileSize = CGSize(width: 32, height: 32)
        let columns = 64
        let rows = 64
        fogLayer = SKTileMapNode(tileSet: tileSet!, columns: columns, rows: rows, tileSize: tileSize)
        
        super.init()

        self.fogLayer.zPosition = 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func initializeTheFog() {
        guard let scene = self.scene as? GameScene else {return}
        scene.map.addChild(fogLayer)
        fogLayer.fill(with: fogLayer.tileSet.tileGroups.first {$0.name == "Fog4"})
        scene.map.enumerateChildNodes(withName: "Units") {
            (node:SKNode, nil) in
            let unit = node as! Units
            if unit.index == scene.localPlayer!.index {
                let position = unit.positionInMap
                for k in 0...unit.discoveryRadius {
                    for i in -k...k {
                        self.fogLayer.setTileGroup(self.fogLayer.tileSet.tileGroups.first {$0.name == "None"}, forColumn: position[0]-k+abs(i), row: position[1]+i)
                        if let index = self.visibleTiles.firstIndex(of: [position[0]-k+abs(i),position[1]+i]) {
                            self.viewers[index] += 1
                        } else {
                            self.visibleTiles.append([position[0]-k+abs(i),position[1]+i])
                            self.viewers.append(1)
                        }
                        guard abs(i)-k != 0 else {continue}
                        
                        self.fogLayer.setTileGroup(self.fogLayer.tileSet.tileGroups.first {$0.name == "None"}, forColumn: position[0]+k-abs(i), row: position[1]+i)
                        if let index = self.visibleTiles.firstIndex(of: [position[0]+k-abs(i),position[1]+i]) {
                            self.viewers[index] += 1
                        } else {
                            self.visibleTiles.append([position[0]+k-abs(i),position[1]+i])
                            self.viewers.append(1)
                        }
                    }
                }
            }
        }
    }
    
    
    
}
