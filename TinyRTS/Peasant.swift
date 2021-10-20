//
//  Peasant.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 14/08/2021.
//

import SpriteKit
import GameplayKit

class Peasant: Units {
    
    enum Collectible {
        case gold, wood, wheat
    }
    
    
    
    var mineAssigned: Mine
    var isMining: Bool = false
    var collectible: Collectible = .wood
    
    var buildingToBuild:Buildings? {
        didSet {
            if  oldValue != nil && buildingToBuild != oldValue && buildingToBuild != nil {
                oldValue?.removeFromParent()
            }
        }
    }
    var isGoingBuilding: Bool = false {
        didSet {
            if !isGoingBuilding {
                buildingToBuild?.removeFromParent()
                buildingToBuild = nil
            }
        }
    }
    
    var gold: Int = 0 {
        willSet {
            if newValue > 0 {
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.1),SKAction.run{
                    self.collectible = .gold
                    guard let farm = self.findNearestFarmFromMe() else {
                        self.removeAllActions()
                        self.action = .idle
                        return
                    }
                    self.removeAllActions()
                    self.action = .idle
                    self.deliverItems(row: farm.positionInMap[1], column: farm.positionInMap[0], wasCollecting: self.collectible)
                }]))
            }
        }
    }
    var wood: Int = 0 {
        willSet {
            if newValue > 5 {
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.1),SKAction.run {
                    self.collectible = .wood
                    guard let farm = self.findNearestFarmFromMe() else {
                        self.removeAllActions()
                        self.action = .idle
                        return
                    }
                    self.removeAllActions()
                    self.action = .idle
                    self.deliverItems(row: farm.positionInMap[1], column: farm.positionInMap[0], wasCollecting: self.collectible)
                }]))
            }
        }
    }
    
    var wheat: Int = 0 {
        willSet {
            if newValue > 5 {
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.1),SKAction.run{
                    self.collectible = .wheat
                    guard let farm = self.findNearestFarmFromMe() else {
                        self.removeAllActions()
                        self.action = .idle
                        return
                    }
                    self.removeAllActions()
                    self.action = .idle
                    self.deliverItems(row: farm.positionInMap[1], column: farm.positionInMap[0], wasCollecting: self.collectible)
                }]))
            }
        }
    }
    
    // MARK: - INIT
    
    override init(race: Race, positionInMap: [Int], index: PlayerType) {
        self.mineAssigned = Mine()
        super.init(race: race,positionInMap: positionInMap,index: index)
        switch self.race {
        case .orc:
            self.unitName = "peon"
        case .human:
            self.unitName = "peasant"
        }
        self.action = .idle
    }
    
    // MARK: - ACTIONS
    
    override func doAction(row: Int, column: Int) {
        guard let scene = self.scene as? GameScene else {return}
        
        self.isGoingBuilding = false
        if checkIfForest(row: row, column: column) {
            harvestWood(row: row, column: column)
        } else if checkIfMine(row: row, column: column) {
            let nodes = scene.map.nodes(at: (scene.mapLayer?.centerOfTile(atColumn: column, row: row))!)
            for i in 0..<nodes.count {
                if nodes[i].zPosition == 3 {
                    self.mineAssigned = nodes[i] as! Mine
                    goMining()
                }
            }
        } else if checkIfWheat(row: row, column: column) {
            harvestWheat(row: row, column: column)
        } else if checkIfFarm(row: row, column: column) {
            deliverItems(row: row, column: column, wasCollecting: collectible)
        } else if let unit = self.checkIfUnits(row: row, column: column), unit.index != scene.localPlayer!.index {
            tryAttacking(node: unit)
        } else {
            
            tryToMoveToLocation(row: row, column: column)
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(self.fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.checkEnemiesAroundMe(radius: 2 + self.range )
            }]))
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(1.2*CGFloat(self.fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.searchAnotherTree(radius: 2)
            }]))
        }
    }
    
    // MARK: - ANIMATIONS
    
    
    func earnCollectible(collectible: Collectible, amount: Int) {
        var texture: SKTexture
        switch collectible {
        case .gold:
            texture = SKTexture(imageNamed: "goldBar", filter: .nearest)
        case .wheat:
            texture = SKTexture(imageNamed: "wheatIcon", filter: .nearest)
        case .wood:
            texture = SKTexture(imageNamed: "wood", filter: .nearest)
        }
        let sprite = SKSpriteNode(texture: texture, color: UIColor.red, size: CGSize(width: 20, height: 20))
        let label = SKLabelNode(fontNamed: "qwerty-two")
        label.fontColor = UIColor.green
        label.text = "+\(amount)"
        label.fontSize = 20
        label.horizontalAlignmentMode = .right
        label.verticalAlignmentMode = .center
        sprite.addChild(label)
        label.position = CGPoint(x: -15 , y: 0)
        sprite.zPosition = 4
        self.addChild(sprite)
        sprite.run(SKAction.moveBy(x: 0, y: 40, duration: 1))
        sprite.run(SKAction.sequence([SKAction.scale(to: 0.7, duration: 1.2),SKAction.scale(to: 0, duration: 0.1)]),completion: {
            sprite.removeFromParent()
        })
        
        
    }
    
    // MARK: - DELIVER ITEMS
    
    func findNearestFarmFromMe() -> Farm? {
        guard let scene = self.scene as? GameScene else {return nil}
        var minDistance: CGFloat = 100000
        var nearestFarm: Farm?
        scene.map.enumerateChildNodes(withName: "Buildings") {
            (node: SKNode, nil) in
            let building = node as! Buildings
            if building.buildingType == .farm && building.index == self.index {
                let xCoordinate = building.position.x - self.position.x
                let yCoordinate = building.position.y - self.position.y
                let distance = sqrt(xCoordinate*xCoordinate+yCoordinate*yCoordinate)
                if distance < minDistance {
                    minDistance = distance
                    nearestFarm = building as? Farm
                }
            }
        }
        return nearestFarm
    }
    
    func deliverItems(row: Int, column: Int, wasCollecting collectible: Collectible) {
        guard let scene = self.scene as? GameScene else {return}
        let amountOfTilesFromFarm = abs(self.positionInMap[0]-column)+abs(self.positionInMap[1]-row)
        if amountOfTilesFromFarm <= 2 {
            scene.gui.amountOfWood += self.wood
            scene.gui.amountOfGold += self.gold
            scene.gui.amountOfWheat += self.wheat
            self.gold = 0
            self.wood = 0
            self.wheat = 0
            switch collectible {
            case .gold:
                self.goMining()
            case .wood:
                searchAnotherTree(radius: 8)
                
            case .wheat:
                searchWheat(radius: 8)
            }
        } else {
            
            tryToMoveToLocation(row: row, column: column)
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                self.action = .idle
                self.deliverItems(row: row, column: column, wasCollecting: collectible)
            }]))
        }
        
    }
    
    private func checkIfFarm(row: Int, column: Int) -> Bool {
        guard let scene = self.scene as? GameScene else {return false}
        let nodesTouched = scene.map.nodes(at: (scene.mapLayer?.centerOfTile(atColumn: column, row: row))!)
        var nodeTouched = SKNode()
        for i in 0..<nodesTouched.count {
            if nodesTouched[i].zPosition == 1 {
                nodeTouched = nodesTouched[i]
            }
        }
        if let _ = nodeTouched as? Farm {
            return true
        } else {
            return false
        }
    }
    
    
    
    // MARK: - BUILD
    
    
    
    // MARK: Walk to place
    
    func goStartBuilding(building: Buildings, row: Int, column: Int) {
        buildingToBuild = building
        isGoingBuilding = true
        guard let scene = self.scene as? GameScene else {return}
        let tileLeft = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column-1),Int32(row)))
        let tileDown = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row-1)))
        
        guard tileLeft != nil || tileDown != nil || self.positionInMap == [column-1,row] || self.positionInMap == [column,row-1] else {
            self.removeAllActions()
            self.action = .idle
            scene.showError(type: .build)
            return}
        
        if self.positionInMap == [column-1,row] || self.positionInMap == [column, row-1]{
            self.buildingToBuild = nil
            self.isGoingBuilding = false
            self.startTheBuilding(building: building, row: row, column: column)
        } else {
            var tiles: [[Int]] = []
            if tileLeft != nil {
                tiles.append([column-1,row])
            }
            if tileDown != nil {
                tiles.append([column,row-1])
            }
            
            let position = findTheNearestTileFromMe(Tiles: tiles)
            tryToMoveToLocation(row: position[1], column: position[0])
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                self.action = .idle
                self.goStartBuilding(building: building, row: row, column: column)
            }]))
        }
    }
    
    // MARK: Start and Build
    
    private func startTheBuilding(building: Buildings, row: Int, column: Int) {
        guard let scene = self.scene as? GameScene else {return}
        var obstacles = [GKGridGraphNode]()
        let amountOfWidthTile = building.size.width/32
        let amountofHeightTile = building.size.height/32
        for i in 0..<Int(amountOfWidthTile) {
            for j in 0..<Int(amountofHeightTile) {
                let row = scene.mapLayer?.tileRowIndex(fromPosition: CGPoint(x: building.position.x + CGFloat(32*i), y: building.position.y + CGFloat(32*j)))
                let column = scene.mapLayer?.tileColumnIndex(fromPosition: CGPoint(x: building.position.x + CGFloat(32*i), y: building.position.y + CGFloat(32*j)))
                guard let obstacleNode = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column!),Int32(row!))) else {
                    scene.showError(type: .space)
                    building.removeFromParent()
                    self.action = .idle
                    return
                }
                obstacles.append(obstacleNode)
            }
        }
        scene.gridGraph.remove(obstacles)
        building.positionInMap = [column, row]
        building.alpha = 1
        building.texture = SKTexture(imageNamed: "construction", filter: .nearest)
        building.setupMyArea()
        buildTheBuilding(building: building)
    }
    
    // MARK: Build The Building
    
    func buildTheBuilding(building: Buildings) {
        guard let scene = self.scene as? GameScene else {return}
        let tileLeft = scene.gridGraph.node(atGridPosition: vector_int2(Int32(building.positionInMap[0]-1),Int32(building.positionInMap[1])))
        let tileDown = scene.gridGraph.node(atGridPosition: vector_int2(Int32(building.positionInMap[0]),Int32(building.positionInMap[1]-1)))
        
        guard tileLeft != nil || tileDown != nil || self.positionInMap == [building.positionInMap[0]-1,building.positionInMap[1]] || self.positionInMap == [building.positionInMap[0],building.positionInMap[1]-1] else {
            scene.showError(type: .build)
            self.removeAllActions()
            self.isSelected = false
            self.action = .idle
            return}
        
        if self.positionInMap == [building.positionInMap[0]-1,building.positionInMap[1]] || self.positionInMap == [building.positionInMap[0],building.positionInMap[1]-1] {
            self.nextDirection = self.positionInMap == [building.positionInMap[0]-1,building.positionInMap[1]] ? .right : .up
            self.nextAction = .attack
            self.update()
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run {
                if building.builtPercentage < 100 {
                    building.builtPercentage += building.builtPercentageIncrease
                } else {
                    self.removeAllActions()
                    self.action = .idle
                }
                if building.builtPercentage >= 100 {
                    self.removeAllActions()
                    self.action = .idle
                }
            }])))
        } else {
            var tiles: [[Int]] = []
            if tileLeft != nil {
                tiles.append([building.positionInMap[0]-1,building.positionInMap[1]])
            }
            if tileDown != nil {
                tiles.append([building.positionInMap[0],building.positionInMap[1]-1])
            }
            
            let position = findTheNearestTileFromMe(Tiles: tiles)
            tryToMoveToLocation(row: position[1], column: position[0])
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                self.action = .idle
                self.buildTheBuilding(building: building)
            }]))
        }
    }
    
    
    // MARK: - MINE
    
    private func checkIfMine(row: Int, column: Int) -> Bool {
        guard let scene = self.scene as? GameScene else {return false}
        guard let definition = scene.mapLayer!.tileDefinition(atColumn: column, row: row) else {return false}
        guard let userData = definition.userData else {return false}
        guard let typeAny = userData["type"] else {return false}
        let type = typeAny as! String
        if type == "mine" {
            return true
        } else {
            return false
        }
    }
    
    private func goMining() {
        guard let scene = self.scene as? GameScene else {return}
        let mineNode = self.mineAssigned
        let mineEntry = mineNode.position
        let rowEntry = (scene.mapLayer?.tileRowIndex(fromPosition: mineEntry))!
        let columnEntry = (scene.mapLayer?.tileColumnIndex(fromPosition: mineEntry))!
        
        
        
        let amountOfTilesFromMine = abs(self.positionInMap[0]-columnEntry)+abs(self.positionInMap[1]-rowEntry)
        if amountOfTilesFromMine <= 2 {
            self.removeAllActions()
            self.isMining(mineNode: mineNode)
        } else {
            
            tryToMoveToLocation(row: rowEntry, column: columnEntry)
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                self.action = .idle
                self.goMining()
            }]))
        }
        
    }
    
    private func isMining(mineNode: Mine) {
        self.run(SKAction.sequence([SKAction.run{
            guard mineNode.miners < 3 else {
                self.removeAllActions()
                self.action = .idle
                return
            }
            mineNode.miners += 1
            self.isMining = true
        },SKAction.scale(to: 0.5, duration: 1),SKAction.run {
            self.action = .attack
        },SKAction.wait(forDuration: 6),SKAction.scale(to: 1, duration: 1)]),completion: {
            mineNode.amountOfGold -= 1
            mineNode.miners -= 1
            self.isMining = false
            self.earnCollectible(collectible: .gold, amount: 1)
            self.gold += 1
        })
    }
    
    
    // MARK: - WHEAT
    
    
    
    // MARK: Harvest
    
    private func harvestWheat(row: Int, column: Int ) {
        guard let scene = self.scene as? GameScene else {return}
        let tile = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row)))
        let amountOfTilesFromWheat = abs(self.positionInMap[0]-column)+abs(self.positionInMap[1]-row)
        
        guard tile != nil || amountOfTilesFromWheat == 0 else {
            self.searchWheat(radius: 4)
            return
        }
        
        if amountOfTilesFromWheat == 0 {
            // Si je suis arrivé à bon port, je change ma direction et mon action puis je m'update pour commencer à découper
            if self.positionInMap[0] == column {
                self.nextDirection = self.positionInMap[1] == row+1 ? .down : .up
                self.nextAction = .attack
            } else {
                self.nextDirection = self.positionInMap[0] == column+1 ? .left : .right
                self.nextAction = .attack
            }
            self.update()
            // Ensuite, je coupe toutes les 1.6 secondes
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run {
                let nodes = scene.map.nodes(at: (scene.mapLayer?.centerOfTile(atColumn: column, row: row))!)
                if let wheatNode = nodes.first(where: {$0.zPosition == 3}) as? Wheat {
                    if wheatNode.amountOfWheat <= 0 {
                        wheatNode.removeFromParent()
                        self.removeAllActions()
                        self.cutWheat(row: row, column: column)
                    } else {
                        wheatNode.amountOfWheat-=2
                        self.earnCollectible(collectible: .wheat, amount: 2)
                        self.wheat += 2
                    }
                } else {
                    // Si il est abattu par un autre, on arrête tout et on cherche un autre arbre collé à moi ou à l'arbre qui a été abattu
                    self.removeAllActions()
                    self.searchWheat(radius: 3)
                }
            }])))
            
        } else {
            
            tryToMoveToLocation(row: row, column: column)
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(self.fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                if self.checkIfWheat(row: row, column: column) {
                    self.harvestWheat(row: row, column: column)
                } else {
                    self.searchWheat(radius: 3)
                }
            }]))
            
        }
        
    }
    
    // MARK: Check Wheat
    
    private func checkIfWheat(row: Int, column: Int) -> Bool {
        // Check si le tile est une forêt
        guard let scene = self.scene as? GameScene else {return false}
        guard let definition = scene.mapBackground!.tileDefinition(atColumn: column, row: row) else {return false}
        guard let userData = definition.userData else {return false}
        guard let typeAny = userData["type"] else {return false}
        let type = typeAny as! String
        if type == "wheat" {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Cut Wheat
    
    private func cutWheat(row: Int, column: Int) {
        // Coupe l'arbre et cherche un autre arbre
        guard let scene = self.scene as? GameScene else {return}
        scene.mapBackground?.setTileGroup(scene.mapLayer?.tileSet.tileGroups.first {$0.name == "CutWheat"}, forColumn: column, row: row)
        
        scene.smallMessage.position = [column,row]
        scene.sendSmallInfo()
        
        searchWheat(radius: 2)
        
    }
    
    // MARK: Search Wheat
    
    func searchWheat(radius: Int) {
        // Cherche un autre arbre proche
        guard let scene = self.scene as? GameScene else {return}
        for k in 1...radius {
            for i in -k...k {
                for j in (-k+abs(i))...(k-abs(i)) {
                    if checkIfWheat(row: positionInMap[1]+i, column: positionInMap[0]+j) {
                        let tile = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionInMap[0]+j),Int32(positionInMap[1]+i)))
                        guard tile != nil else {
                            continue
                        }
                        self.removeAllActions()
                        harvestWheat(row: positionInMap[1]+i, column: positionInMap[0]+j)
                        return
                    } else {
                        continue
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - FOREST
    
    
    
    // MARK: Harvest
    
    private func harvestWood(row: Int, column: Int) {
        
        // PEASANT MANAGEMENT
        
        guard let scene = self.scene as? GameScene else {return}
        let tileDown = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row-1)))
        let tileUp = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row+1)))
        let tileRight = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column+1),Int32(row)))
        let tileLeft = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column-1),Int32(row)))
        let amountOfTilesFromTree = abs(self.positionInMap[0]-column)+abs(self.positionInMap[1]-row)
        
        guard tileDown != nil || tileUp != nil || tileRight != nil || tileLeft != nil || amountOfTilesFromTree == 1 else {
            self.tryToMoveToLocation(row: row, column: column)
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                print(5)
                self.searchAnotherTree(radius: 6)
            }]))
            return
        }
        
        if amountOfTilesFromTree == 1 {
            // Si je suis arrivé à bon port, je change ma direction et mon action puis je m'update pour commencer à découper
            if self.positionInMap[0] == column {
                self.nextDirection = self.positionInMap[1] == row+1 ? .down : .up
                self.nextAction = .attack
            } else {
                self.nextDirection = self.positionInMap[0] == column+1 ? .left : .right
                self.nextAction = .attack
            }
            self.update()
            // Ensuite, je coupe toutes les 1.6 secondes
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run {
                let nodes = scene.map.nodes(at: (scene.mapLayer?.centerOfTile(atColumn: column, row: row))!)
                if let forestNode = nodes.first(where: {$0.zPosition == 3}) as? Forest {
                    if forestNode.amountOfWood <= 0 {
                        self.removeAllActions()
                        print(4)
                        self.cutTree(row: row, column: column)
                        // Si on l'abat, on retire la node
                        forestNode.removeFromParent()
                    } else {
                        forestNode.amountOfWood-=2
                        self.earnCollectible(collectible: .wood, amount: 2)
                        self.wood += 2
                    }
                } else {
                    // Si il est abattu par un autre, on arrête tout et on cherche un autre arbre collé à moi ou à l'arbre qui a été abattu
                    self.removeAllActions()
                    print(3)
                    self.searchAnotherTree(radius: 4)
                }
            }])))
        } else {
            tryToMoveToLocation(row: row, column: column)
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(self.fastestPathToLocation!.count)*32.0/celerity)+0.1),SKAction.run {
                self.removeAllActions()
                if self.checkIfForest(row: row, column: column) {
                    self.harvestWood(row: row, column: column)
                } else {
                    self.searchAnotherTree(radius: 4)
                }
            }]))
            
        }
    }
    
    // MARK: Check Forest
    
    private func checkIfForest(row: Int, column: Int) -> Bool {
        // Check si le tile est une forêt
        guard let scene = self.scene as? GameScene else {return false}
        guard let definition = scene.mapLayer!.tileDefinition(atColumn: column, row: row) else {return false}
        guard let userData = definition.userData else {return false}
        guard let typeAny = userData["type"] else {return false}
        let type = typeAny as! String
        if type == "forest" {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Cut Tree
    
    private func cutTree(row: Int, column: Int) {
        // Coupe l'arbre et cherche un autre arbre
        guard let scene = self.scene as? GameScene else {return}
        scene.gridGraph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(column),Int32(row))))
        scene.mapLayer?.setTileGroup(nil, forColumn: column, row: row)
        scene.mapBackground?.setTileGroup(scene.mapLayer?.tileSet.tileGroups.first {$0.name == "5cutTrees"}, forColumn: column, row: row)
        
        scene.smallMessage.position = [column,row]
        scene.sendSmallInfo()
        searchAnotherTree(radius: 4)
        
    }
    
    // MARK: Go Next Tree
    
    func searchAnotherTree(radius: Int) {
        // Cherche un autre arbre proche
        guard let scene = self.scene as? GameScene else {return}
        for k in 1...radius {
            for i in -k...k {
                for j in (-k+abs(i))...(k-abs(i)) {
                    let row = positionInMap[1]+i
                    let column = positionInMap[0]+j
                    if checkIfForest(row: positionInMap[1]+i, column: positionInMap[0]+j) {
                        let tileDown = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row-1)))
                        let tileUp = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row+1)))
                        let tileRight = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column+1),Int32(row)))
                        let tileLeft = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column-1),Int32(row)))
                        let amountOfTilesFromTree = abs(self.positionInMap[0]-column)+abs(self.positionInMap[1]-row)
                        
                        guard tileDown != nil || tileUp != nil || tileRight != nil || tileLeft != nil || amountOfTilesFromTree == 1 else {
                            continue
                        }
                        
                        self.removeAllActions()
                        print(1)
                        harvestWood(row: positionInMap[1]+i, column: positionInMap[0]+j)
                        return
                    } else {
                        continue
                    }
                }
            }
        }
    }
    
    private func searchNearestAvailableTree() -> [Int] {
        guard let scene = self.scene as? GameScene else {return []}
        print("searching..")
        for k in 0..<10 {
            for i in -k...k {
                for j in (-k+abs(i))...(k-abs(i)) {
                    if checkIfForest(row: positionInMap[1]+i, column: positionInMap[0]+j) {
                        let tileDown = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionInMap[0]+j),Int32(positionInMap[1]+i-1)))
                        let tileUp = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionInMap[0]+j),Int32(positionInMap[1]+i+1)))
                        let tileRight = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionInMap[0]+j+1),Int32(positionInMap[1]+i)))
                        let tileLeft = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionInMap[0]+j-1),Int32(positionInMap[1]+i)))
                        if tileDown != nil || tileUp != nil || tileRight != nil || tileLeft != nil {
                            return [positionInMap[0]+j,positionInMap[1]+i]
                        }
                    }
                }
            }
        }
        return [65,65]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
