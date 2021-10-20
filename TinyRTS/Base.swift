//
//  Base.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 15/08/2021.
//

import SpriteKit
import GameplayKit

class Base: Buildings {
    
    
    init(race: Race, index: PlayerType) {
        let texture = SKTexture(imageNamed: "construction", filter: .nearest)
        super.init(texture: texture,size: CGSize(width: 64, height: 64), race: race, index: index)
        self.buildingType = .base
        self.finishTexture = SKTexture(imageNamed: "\(race)"+"Base", filter: .nearest)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doAction() {
        spawnAPeasant()
    }
    
    func spawnAPeasant() {
        guard let scene = self.scene as? GameScene else {return}
        let spawnPosition = self.findNearestAvailableTileFrom(positionInMap: self.positionInMap.reversed())
        let peasant = Peasant(race: self.race, positionInMap: [spawnPosition[1],spawnPosition[0]],index: self.index)
        peasant.unitNumber = scene.giveAnEntityNumber()
        scene.map.addChild(peasant)
        let nodeUnderUnit = scene.gridGraph.node(atGridPosition: vector_int2(Int32(spawnPosition[1]),Int32(spawnPosition[0])))
        scene.gridGraph.remove([nodeUnderUnit!])
        peasant.position = (scene.mapLayer?.centerOfTile(atColumn: spawnPosition[1], row: spawnPosition[0]))!
        peasant.setupMyArea()
    }
    
    
}
