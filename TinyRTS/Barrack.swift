//
//  Barracks.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 26/08/2021.
//

import SpriteKit
import GameplayKit

class Barrack: Buildings {
    
    init(race: Race, index: PlayerType) {
        let texture = SKTexture(imageNamed: "construction", filter: .nearest)
        super.init(texture: texture,size: CGSize(width: 32, height: 32),race: race,index: index)
        self.buildingType = .barrack
        self.finishTexture = SKTexture(imageNamed: "\(race)"+"Barrack", filter: .nearest)
        self.builtPercentageIncrease = 50
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnASoldier() {
        guard let scene = self.scene as? GameScene else {return}
        let spawnPosition = self.findNearestAvailableTileFrom(positionInMap: self.positionInMap.reversed())
        let soldier = Soldier(race: race, positionInMap: [spawnPosition[1],spawnPosition[0]],index: self.index)
        soldier.unitNumber = scene.giveAnEntityNumber()
        scene.map.addChild(soldier)
        let nodeUnderUnit = scene.gridGraph.node(atGridPosition: vector_int2(Int32(spawnPosition[1]),Int32(spawnPosition[0])))
        scene.gridGraph.remove([nodeUnderUnit!])
        soldier.position = (scene.mapLayer?.centerOfTile(atColumn: spawnPosition[1], row: spawnPosition[0]))!
        soldier.setupMyArea()
    }
    
    func spawnAWolf() {
        guard let scene = self.scene as? GameScene else {return}
        let spawnPosition = self.findNearestAvailableTileFrom(positionInMap: self.positionInMap.reversed())
        let wolf = Wolf(race: race, positionInMap: [spawnPosition[1],spawnPosition[0]],index: self.index)
        wolf.unitNumber = scene.giveAnEntityNumber()
        scene.map.addChild(wolf)
        let nodeUnderUnit = scene.gridGraph.node(atGridPosition: vector_int2(Int32(spawnPosition[1]),Int32(spawnPosition[0])))
        scene.gridGraph.remove([nodeUnderUnit!])
        wolf.position = (scene.mapLayer?.centerOfTile(atColumn: spawnPosition[1], row: spawnPosition[0]))!
        wolf.setupMyArea()
    }
    
    func spawnAnAmbassador() {
        guard let scene = self.scene as? GameScene else {return}
        let spawnPosition = self.findNearestAvailableTileFrom(positionInMap: self.positionInMap.reversed())
        let ambassador = Ambassador(race: race, positionInMap: [spawnPosition[1],spawnPosition[0]],index: self.index)
        ambassador.unitNumber = scene.giveAnEntityNumber()
        scene.map.addChild(ambassador)
        let nodeUnderUnit = scene.gridGraph.node(atGridPosition: vector_int2(Int32(spawnPosition[1]),Int32(spawnPosition[0])))
        scene.gridGraph.remove([nodeUnderUnit!])
        ambassador.position = (scene.mapLayer?.centerOfTile(atColumn: spawnPosition[1], row: spawnPosition[0]))!
        ambassador.setupMyArea()
    }
    
    func spawnAnArcher() {
        guard let scene = self.scene as? GameScene else {return}
        let spawnPosition = self.findNearestAvailableTileFrom(positionInMap: self.positionInMap.reversed())
        let archer = Archer(race: race, positionInMap: [spawnPosition[1],spawnPosition[0]],index: self.index)
        archer.unitNumber = scene.giveAnEntityNumber()
        scene.map.addChild(archer)
        let nodeUnderUnit = scene.gridGraph.node(atGridPosition: vector_int2(Int32(spawnPosition[1]),Int32(spawnPosition[0])))
        scene.gridGraph.remove([nodeUnderUnit!])
        archer.position = (scene.mapLayer?.centerOfTile(atColumn: spawnPosition[1], row: spawnPosition[0]))!
        archer.setupMyArea()
    }
    
    func spawnAWizard() {
        guard let scene = self.scene as? GameScene else {return}
        let spawnPosition = self.findNearestAvailableTileFrom(positionInMap: self.positionInMap.reversed())
        let wizard = Wizard(race: race, positionInMap: [spawnPosition[1],spawnPosition[0]],index: self.index)
        wizard.unitNumber = scene.giveAnEntityNumber()
        scene.map.addChild(wizard)
        let nodeUnderUnit = scene.gridGraph.node(atGridPosition: vector_int2(Int32(spawnPosition[1]),Int32(spawnPosition[0])))
        scene.gridGraph.remove([nodeUnderUnit!])
        wizard.position = (scene.mapLayer?.centerOfTile(atColumn: spawnPosition[1], row: spawnPosition[0]))!
        wizard.setupMyArea()
    }
    
    
}
