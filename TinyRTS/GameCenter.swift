//
//  GameCenter.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 27/08/2021.
//

import SpriteKit
import GameKit


extension GameScene: GKMatchDelegate {
    
    func sendData() {
            guard let match = match else {return}
            do {
                guard let data = gameModel.encode() else { return }
                try match.sendData(toAllPlayers: data, with: .unreliable)
            } catch {
                //print("Send data failed")
            }
        }
    
    func sendSmallInfo() {
        guard let match = match else {return}
        do {
            guard let data = smallMessage.encode() else {return}
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Send smallMessage failed")
        }
    }
    
    // MARK: - UPDATE
    
    private func update() {
        var buildingPositionArray: [CGPoint] = []
        var buildingTypeArray: [Buildings.BuildingType] = []
        var builtPercentageArray: [Int] = []
        
        var unitTypeArray: [Units.UnitType]
        var positionArray: [CGPoint]
        var actionArray: [Units.Action]
        var directionArray: [Units.Direction]
        var nextPositionInMapArray: [[Int]]
        var positionInMapArray: [[Int]]
        
        var enemyLifeArray: [Int] = []
        if localPlayer!.index == .one {
            buildingPositionArray = self.gameModel.buildingPositionArray2
            buildingTypeArray = self.gameModel.buildingTypeArray2
            builtPercentageArray = self.gameModel.builtPercentageArray2
            
            unitTypeArray = self.gameModel.unitTypeArray2
            positionArray = self.gameModel.positionArray2
            actionArray = self.gameModel.actionArray2
            directionArray = self.gameModel.directionArray2
            nextPositionInMapArray = self.gameModel.nextPositionInMapArray2
            positionInMapArray = self.gameModel.positionInMapArray2
            
            enemyLifeArray = self.gameModel.enemyLifeArray2
        } else {
            buildingPositionArray = self.gameModel.buildingPositionArray
            buildingTypeArray = self.gameModel.buildingTypeArray
            builtPercentageArray = self.gameModel.builtPercentageArray
            
            unitTypeArray = self.gameModel.unitTypeArray
            positionArray = self.gameModel.positionArray
            actionArray = self.gameModel.actionArray
            directionArray = self.gameModel.directionArray
            nextPositionInMapArray = self.gameModel.nextPositionInMapArray
            positionInMapArray = self.gameModel.positionInMapArray
            
            enemyLifeArray = self.gameModel.enemyLifeArray
        }
        guard positionArray.count > 0 else {return}
        guard enemyLifeArray.count > 0 else {return}
        
        // MARK: Units
        
        var ownUnits: [Units] = []
        var enemyUnits: [Units] = []
        var enemyUnitIndex = 0
        map.enumerateChildNodes(withName: "Units") {
            (node:SKNode, nil) in
            let unit = node as? Units
            if unit!.index != self.localPlayer!.index {
                /* if enemyUnitIndex < positionArray.count {
                    unit?.position = positionArray[enemyUnitIndex]
                    unit?.nextPositionInMap = nextPositionInMapArray[enemyUnitIndex]
                    unit?.positionInMap = positionInMapArray[enemyUnitIndex]
                    if unit!.action != actionArray[enemyUnitIndex] || unit!.direction != directionArray[enemyUnitIndex] {
                        unit?.action = actionArray[enemyUnitIndex]
                        unit?.direction = directionArray[enemyUnitIndex]
                    }
                } */
                enemyUnits.append(unit!)
            } else {
                ownUnits.append(unit!)
            }
        }
        
        var enemyPlayer: Player
        if self.localPlayer!.displayName == gameModel.players[0].displayName {
            enemyPlayer = gameModel.players[1]
        } else {
            enemyPlayer = gameModel.players[0]
        }
        
        if ownUnits.count == enemyLifeArray.count {
            for i in 0..<ownUnits.count {
                if ownUnits[i].life > enemyLifeArray[i] {
                    ownUnits[i].life = enemyLifeArray[i]
                    if ownUnits[i].life <= 0 {
                        ownUnits[i].updateFogOnDeath()
                        ownUnits[i].die()
                    }
                }
            }
        }
        
        if enemyUnits.count == positionArray.count {
            for i in 0..<enemyUnits.count {
                enemyUnits[i].position = positionArray[i]
                enemyUnits[i].nextPositionInMap = nextPositionInMapArray[i]
                enemyUnits[i].positionInMap = positionInMapArray[i]
                if enemyUnits[i].action != actionArray[i] || enemyUnits[i].direction != directionArray[i] {
                    enemyUnits[i].action = actionArray[i]
                    enemyUnits[i].direction = directionArray[i]
                }
            }
        } else if enemyUnits.count > positionArray.count {
            for i in 0..<enemyUnits.count {
                if enemyUnits[i].life <= 0 {
                    enemyUnits[i].die()
                }
            }
        } else {
            for i in enemyUnits.count..<positionArray.count {
                let position = positionArray[i]
                let unitType = unitTypeArray[i]
                let column = (mapLayer?.tileColumnIndex(fromPosition: position))!
                let row = (mapLayer?.tileRowIndex(fromPosition: position))!
                var unit: Units
                switch unitType {
                case .peasant:
                    unit = Peasant(race: enemyPlayer.race, positionInMap: [column,row], index: enemyPlayer.index)
                case .soldier:
                    unit = Soldier(race: enemyPlayer.race, positionInMap: [column,row], index: enemyPlayer.index)
                case .wolf:
                    unit = Wolf(race: enemyPlayer.race, positionInMap: [column,row], index: enemyPlayer.index)
                case .ambassador:
                    unit = Ambassador(race: enemyPlayer.race, positionInMap: [column,row], index: enemyPlayer.index)
                case .archer:
                    unit = Archer(race: enemyPlayer.race, positionInMap: [column,row], index: enemyPlayer.index)
                case .wizard:
                    unit = Wizard(race: enemyPlayer.race, positionInMap: [column,row], index: enemyPlayer.index)
                }
                map.addChild(unit)
                unit.position = position
            }
        }
        
        if self.localPlayer!.index == .two {
            if let position = self.gameModel.positionInMapArray2.haveTheSameElement(as: self.gameModel.positionInMapArray)[0] as? [Int] {
                self.gridGraph.remove([GKGridGraphNode(gridPosition: vector_int2(Int32(position[0]),Int32(position[1])))])
                map.enumerateChildNodes(withName: "Units") {
                    (node:SKNode, nil) in
                    let unit = node as! Units
                    if unit.index == .two && unit.nextPositionInMap == position {
                        let positionToGo = unit.findTheNearestTileFromMe(Tiles: unit.findNearestAvailableTilesFrom(positionInMap: position))
                        unit.tryToMoveToLocation(row: positionToGo[1], column: positionToGo[0])
                    }
                }
            }
        }
        
        
        // MARK: Batîments
        for i in 0..<buildingPositionArray.count {
            var node: SKNode?
            let nodes = map.nodes(at: buildingPositionArray[i])
            for j in 0..<nodes.count {
                if nodes[j].zPosition == 1 {
                    node = nodes[j]
                }
            }
            
            // On gère les batîments
            
            if let building = node as? Buildings {
                if building.builtPercentage != builtPercentageArray[i] && building.builtPercentage < 100 {
                    building.builtPercentage = builtPercentageArray[i]
                }
            } else {
                var building: Buildings
                switch buildingTypeArray[i] {
                case .base:
                    building = Base(race: enemyPlayer.race, index: enemyPlayer.index)
                case .farm:
                    building = Farm(race: enemyPlayer.race, index: enemyPlayer.index)
                case .barrack:
                    building = Barrack(race: enemyPlayer.race, index: enemyPlayer.index)
                case .windmill:
                    building = Windmill(race: enemyPlayer.race, index: enemyPlayer.index)
                case .supply:
                    building = Supply(race: enemyPlayer.race, index: enemyPlayer.index)
                case .tower:
                    building = Tower(race: enemyPlayer.race, index: enemyPlayer.index)
                }
                self.map.addChild(building)
                building.position = buildingPositionArray[i]
                self.NewBuilding(building: building, row: mapLayer!.tileRowIndex(fromPosition: building.position), column: mapLayer!.tileColumnIndex(fromPosition: building.position))
            }
            
        }
        
    }
    
    // MARK: - SMALL UPDATE TYPE
    
    private func isWheat(row: Int, column: Int) -> Bool {
        // Check si le tile est du blé
        guard let definition = mapBackground!.tileDefinition(atColumn: column, row: row) else {return false}
        guard let userData = definition.userData else {return false}
        guard let typeAny = userData["type"] else {return false}
        let type = typeAny as! String
        if type == "wheat" {
            return true
        } else {
            return false
        }
    }
    
    private func isBuilding(row: Int, column: Int) -> Buildings? {
        let nodesTouched = map.nodes(at: (mapLayer?.centerOfTile(atColumn: column, row: row))!)
        if let building = nodesTouched.first(where: {$0.zPosition == 1}) as? Buildings {
            return building
        } else {
            return nil
        }
    }
    
    private func isForest(row: Int, column: Int) -> Bool {
        // Check si le tile est une forêt
        guard let definition = mapLayer!.tileDefinition(atColumn: column, row: row) else {return false}
        guard let userData = definition.userData else {return false}
        guard let typeAny = userData["type"] else {return false}
        let type = typeAny as! String
        if type == "forest" {
            return true
        } else {
            return false
        }
    }
    
    private func isWindmill(row: Int, column: Int) -> Windmill? {
        let nodesTouched = map.nodes(at: (mapLayer?.centerOfTile(atColumn: column, row: row))!)
        var nodeTouched = SKNode()
        for i in 0..<nodesTouched.count {
            if nodesTouched[i].zPosition == 1 {
                nodeTouched = nodesTouched[i]
            }
        }
        if let windmill = nodeTouched as? Windmill {
            return windmill
        } else {
            return nil
        }
    }
    
    // MARK: - SMALL UPDATE
    
    func smallUpdate() {
        let positionInMap = smallMessage.position
        let column = positionInMap[0]
        let row = positionInMap[1]
        if isForest(row: row, column: column) {
            gridGraph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(column),Int32(row))))
            mapLayer?.setTileGroup(nil, forColumn: column, row: row)
            mapBackground?.setTileGroup(mapLayer?.tileSet.tileGroups.first {$0.name == "5cutTrees"}, forColumn: column, row: row)
        } else if isWheat(row: row, column: column) {
            mapBackground?.setTileGroup(mapLayer?.tileSet.tileGroups.first {$0.name == "CutWheat"}, forColumn: column, row: row)
        } else if let windmill = isWindmill(row: row, column: column) {
            windmill.spawnWheat()
        } else if let building = isBuilding(row: row, column: column) {
            building.life = smallMessage.life
            if building.life <= 0 {
                if building.index == self.localPlayer!.index {
                    building.updateFogOnDeath()
                }
                building.die()
                building.removeFromParent()
                destroyBuilding(building: building)
                sendSmallInfo()
            }
        }
        
        
    }
    
    // MARK: - GAMECENTER FUNCS
    
    private func NewBuilding(building: Buildings, row: Int, column: Int) {
        guard let scene = self.scene as? GameScene else {return}
        var obstacles = [GKGridGraphNode]()
        let amountOfWidthTile = building.size.width/32
        let amountofHeightTile = building.size.height/32
        for i in 0..<Int(amountOfWidthTile) {
            for j in 0..<Int(amountofHeightTile) {
                let actualRow = mapLayer?.tileRowIndex(fromPosition: CGPoint(x: building.position.x + CGFloat(32*i), y: building.position.y + CGFloat(32*j)))
                let actualColumn = mapLayer?.tileColumnIndex(fromPosition: CGPoint(x: building.position.x + CGFloat(32*i), y: building.position.y + CGFloat(32*j)))
                guard let obstacleNode = gridGraph.node(atGridPosition: vector_int2(Int32(actualColumn!),Int32(actualRow!))) else {
                    self.run(SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.run {
                        self.NewBuilding(building: building, row: row, column: column)
                    }]))
                    return
                }
                obstacles.append(obstacleNode)
            }
        }
        scene.gridGraph.remove(obstacles)
        building.positionInMap = [column, row]
    }
    
    private func destroyBuilding(building: Buildings) {
        guard let scene = self.scene as? GameScene else {return}
        let amountOfWidthTile = building.size.width/32
        let amountofHeightTile = building.size.height/32
        for i in 0..<Int(amountOfWidthTile) {
            for j in 0..<Int(amountofHeightTile) {
                let actualRow = mapLayer?.tileRowIndex(fromPosition: CGPoint(x: building.position.x + CGFloat(32*i), y: building.position.y + CGFloat(32*j)))
                let actualColumn = mapLayer?.tileColumnIndex(fromPosition: CGPoint(x: building.position.x + CGFloat(32*i), y: building.position.y + CGFloat(32*j)))
                scene.gridGraph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(actualColumn!),Int32(actualRow!))))
            }
        }
    }
    
    
    // MARK: - MATCH
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if let message = SmallMessage.decode(data: data) {
            smallMessage = message
            smallUpdate()
        } else {
            guard let model = GameModel.decode(data: data) else { return }
            gameModel = model
            update()
        }
    }
}
