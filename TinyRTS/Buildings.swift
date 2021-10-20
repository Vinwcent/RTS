//
//  Buildings.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 14/08/2021.
//

import SpriteKit
import GameplayKit

class Buildings: SKSpriteNode {
    
    enum BuildingType: String, Codable, CaseIterable {
        case base, farm, barrack, windmill, supply, tower
    }
    
    var finishTexture: SKTexture?
    
    var life: Int = 10 {
        didSet {
            if life < oldValue {
                showLife()
            }
        }
    }
    var maxLife: Int = 10
    var buildingNumber: Int = 0
    var buildingType: BuildingType = .base
    var race: Race
    var index: PlayerType
    var discoveryRadius: Int = 6
    
    var positionInMap: [Int] = [0,0]
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                guard let scene = self.scene as? GameScene else {return}
                scene.unitSelection.showNothing()
            }
        }
    }
    var isBeingPlaced: Bool = false {
        didSet {
            if isBeingPlaced {
                zPosition = 4
            } else {
                zPosition = 1
            }
        }
    }
    var builtPercentage: Int = 0 {
        didSet {
            if builtPercentage >= 100 {
                self.finishBuilding()
            }
        }
    }
    
    var builtPercentageIncrease: Int = 10
    
    init(texture: SKTexture,size: CGSize,race: Race, index: PlayerType) {
        self.race = race
        self.index = index
        super.init(texture: texture, color: UIColor.red, size: size)
        self.anchorPoint = CGPoint(x: 16/size.width, y: 16/size.height)
        self.zPosition = 1
        self.name = "Buildings"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ANIMATIONS
    
    func finishBuilding() {
        guard let scene = self.scene as? GameScene else {return}
        if let _ = finishTexture {
            self.texture = finishTexture
        }
        
        if self.buildingType == .windmill {
            self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "windmill1", filter: .nearest),SKTexture(imageNamed: "windmill2", filter: .nearest),SKTexture(imageNamed: "windmill3", filter: .nearest),SKTexture(imageNamed: "windmill4", filter: .nearest),SKTexture(imageNamed: "windmill5", filter: .nearest),SKTexture(imageNamed: "windmill6", filter: .nearest),SKTexture(imageNamed: "windmill7", filter: .nearest),SKTexture(imageNamed: "windmill8", filter: .nearest)], timePerFrame: 0.2)))
        } else if self.buildingType == .supply {
            scene.gui.supplyAmount += 5
        } else if self.buildingType == .tower {
            guard let tower = self as? Tower else {return}
            tower.searchEnemies()
        }
    }
    
    private func showLife() {
        self.enumerateChildNodes(withName: "LIFEBAR") {
            (node:SKNode, nil) in
            let lifeBar = node as! SKShapeNode
            lifeBar.removeFromParent()
        }
        
        let maxWidth = Int(size.width-4)
        let width = self.life*maxWidth/self.maxLife
        let rect = CGRect(origin: CGPoint(x: -maxWidth/2, y: -2), size: CGSize(width: width, height: 4))
        let lifeBar = SKShapeNode(rect: rect)
        lifeBar.fillColor = UIColor(red: 150/255, green: 25/255, blue: 21/255, alpha: 1)
        lifeBar.name = "LIFEBAR"
        lifeBar.lineWidth = 0
        self.addChild(lifeBar)
        let lifeHeight = size.height-32+21
        let lifeWidth = (size.width-32)/2
        lifeBar.position = CGPoint(x: lifeWidth, y: lifeHeight)
        lifeBar.run(SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.run {
            lifeBar.removeFromParent()
        }]))
    }
    
    // MARK: - DO ACTIONS
    
    func doAction() {
        return
    }
    
    func die() {
        guard let scene = self.scene as? GameScene else {return}
        let amountOfWidthTile = size.width/32
        let amountofHeightTile = size.height/32
        for i in 0..<Int(amountOfWidthTile) {
            for j in 0..<Int(amountofHeightTile) {
                let deadAnimation = SKSpriteNode(imageNamed: "explosion1")
                deadAnimation.size = CGSize(width: 32, height: 32)
                deadAnimation.zPosition = 1
                scene.map.addChild(deadAnimation)
                deadAnimation.position = CGPoint(x: self.position.x + CGFloat(32*i), y: self.position.y + CGFloat(32*j))
                deadAnimation.run(SKAction.animate(with: [SKTexture(imageNamed:  "explosion1", filter: .nearest),SKTexture(imageNamed:  "explosion2", filter: .nearest),SKTexture(imageNamed:  "explosion3", filter: .nearest),SKTexture(imageNamed:  "explosion4", filter: .nearest),SKTexture(imageNamed:  "explosion5", filter: .nearest),SKTexture(imageNamed:  "explosion6", filter: .nearest),SKTexture(imageNamed:  "explosion7", filter: .nearest)], timePerFrame: 0.2),completion: {
                    deadAnimation.removeFromParent()
                })
            }
        }
    }
    
    // MARK: - FOG
    
    func updateFogOnDeath() {
        guard let scene = self.scene as? GameScene else {return}
        let position = positionInMap
        for k in 0...discoveryRadius {
            for i in -k...k {
                if let index = scene.fog.visibleTiles.firstIndex(of: [position[0]+k-abs(i),position[1]+i]) {
                    scene.fog.viewers[index] -= 1
                    if scene.fog.viewers[index] <= 0 {
                        scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "Fog4"}, forColumn: position[0]+k-abs(i), row: position[1]+i)
                    }
                }
                
                guard abs(i)-k != 0 else {continue}
                
                if let index = scene.fog.visibleTiles.firstIndex(of: [position[0]-k+abs(i),position[1]+i]) {
                    scene.fog.viewers[index] -= 1
                    if scene.fog.viewers[index] <= 0 {
                        scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "Fog4"}, forColumn: position[0]-k+abs(i), row: position[1]+i)
                    }
                }
            }
        }
    }
    
    func setupMyArea() {
        guard let scene = self.scene as? GameScene else {return}
        let position = positionInMap
        for k in 0...discoveryRadius {
            for i in -k...k {
                scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "None"}, forColumn: position[0]+k-abs(i), row: position[1]+i)
                if let index = scene.fog.visibleTiles.firstIndex(of: [position[0]+k-abs(i),position[1]+i]) {
                    scene.fog.viewers[index] += 1
                } else {
                    scene.fog.visibleTiles.append([position[0]+k-abs(i),position[1]+i])
                    scene.fog.viewers.append(1)
                }
                guard abs(i)-k != 0 else {continue}
                
                scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "None"}, forColumn: position[0]-k+abs(i), row: position[1]+i)
                if let index = scene.fog.visibleTiles.firstIndex(of: [position[0]-k+abs(i),position[1]+i]) {
                    scene.fog.viewers[index] += 1
                } else {
                    scene.fog.visibleTiles.append([position[0]-k+abs(i),position[1]+i])
                    scene.fog.viewers.append(1)
                }
            }
        }
    }
    
    // MARK: - BUILDINGS
    
    
    static func spawnBuildings(scene: GameScene, type: Buildings.BuildingType, index: PlayerType) {
        var race: Race
        if index == .one {
            race = scene.gameModel.players[0].race
        } else {
            race = scene.gameModel.players[1].race
        }
        
        switch type {
        case .base:
            let base = Base(race: race, index: index)
            base.isBeingPlaced = true
            base.alpha = 0.5
            scene.map.addChild(base)
            base.position = scene.convert(scene.convertPoint(fromView: scene.view!.center), to: scene.map)
        case .farm:
            let farm = Farm(race: race, index: index)
            farm.isBeingPlaced = true
            farm.alpha = 0.5
            scene.map.addChild(farm)
            farm.position = scene.convert(scene.convertPoint(fromView: scene.view!.center), to: scene.map)
        case .barrack:
            let barrack = Barrack(race: race, index: index)
            barrack.isBeingPlaced = true
            barrack.alpha = 0.5
            scene.map.addChild(barrack)
            barrack.position = scene.convert(scene.convertPoint(fromView: scene.view!.center), to: scene.map)
        case .windmill:
            let windmill = Windmill(race: race, index: index)
            windmill.isBeingPlaced = true
            windmill.alpha = 0.5
            scene.map.addChild(windmill)
            windmill.position = scene.convert(scene.convertPoint(fromView: scene.view!.center), to: scene.map)
        case .supply:
            let supply = Supply(race: race, index: index)
            supply.isBeingPlaced = true
            supply.alpha = 0.5
            scene.map.addChild(supply)
            supply.position = scene.convert(scene.convertPoint(fromView: scene.view!.center), to: scene.map)
        case .tower:
            let tower = Tower(race: race, index: index)
            tower.isBeingPlaced = true
            tower.alpha = 0.5
            scene.map.addChild(tower)
            tower.position = scene.convert(scene.convertPoint(fromView: scene.view!.center), to: scene.map)
        }
        scene.menuNode.showThePlacingMenu()
    }
    
    
    
    
    
    
    
    
    
    
    func findNearestAvailableTileFrom(positionInMap: [Int]) -> [Int] {
        // Fonction qui trouve le tile disponible le plus proche d'une position donné.
        guard let scene = self.scene as? GameScene else {return []}
        var minDistance: CGFloat = 100000
        var nearestDistance = [Int]()
        for column in 0..<scene.mapLayer!.numberOfColumns {
            for row in 0..<scene.mapLayer!.numberOfRows {
                guard let locationNode = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row))) else {continue}
                let xCoordinate = (scene.mapLayer?.centerOfTile(atColumn: positionInMap[1], row: positionInMap[0]).x)!-(scene.mapLayer?.centerOfTile(atColumn: column, row: row).x)!
                let yCoordinate = (scene.mapLayer?.centerOfTile(atColumn: positionInMap[1], row: positionInMap[0]).y)!-(scene.mapLayer?.centerOfTile(atColumn: column, row: row).y)!
                let distance = sqrt(xCoordinate*xCoordinate+yCoordinate*yCoordinate)
                if distance < minDistance {
                    minDistance = distance
                    nearestDistance = [row, column]
                }
                
            }
        }
        return nearestDistance
    }
    
    
}
