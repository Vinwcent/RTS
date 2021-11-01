//
//  Units.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 14/08/2021.
//

import SpriteKit
import GameplayKit


class Units: SKSpriteNode {
    
    // MARK: - VARS/ENUMS
    
    enum UnitType: String, Codable, CaseIterable {
        case peasant, soldier, wolf, ambassador, archer, wizard
    }
    
    enum Action: String, Codable, CaseIterable {
        case idle, walk, attack
    }
    
    enum Direction: String, Codable, CaseIterable {
        case down, left, up, right
    }
    
    var unitNumber: Int = 0
    var unitType: UnitType = .peasant
    var race: Race
    var index: PlayerType
    var failCounter: Int = 0
    var unitName: String = "None"
    
    var discoveryRadius: Int = 10
    var attack: Int = 1
    var range: Int = 2
    var celerity: CGFloat = 32
    var maxLife = 5
    var life = 5 {
        didSet {
            guard life < oldValue else {return}
            self.showLife()
            guard let scene = self.scene as? GameScene else {return}
            if self.index == scene.localPlayer?.index {
                if self.action == .idle {
                    checkEnemiesAroundMe(radius: 2 + self.range)
                } else if self.action == .attack {
                    callAlliesAroundMe()
                }
                
            }
            self.run(SKAction.sequence([SKAction.colorize(with: .red, colorBlendFactor: 0.7, duration:0.15),SKAction.wait(forDuration:0.1),SKAction.colorize(withColorBlendFactor: 0.0, duration:0.15)]),withKey: "Touched")
            if isSelected {
                scene.unitSelection.showSelectedUnits(amount: scene.unitSelection.amountSelected)
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            if let peasant = self as? Peasant {
                guard !peasant.isMining else {
                    isSelected = false
                    return
                }
            }
            
            if isSelected {
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: .brown, colorBlendFactor: 0.7, duration:0.3),SKAction.wait(forDuration:0.1),SKAction.colorize(withColorBlendFactor: 0.0, duration:0.3)])),withKey: "Selected")
            } else {
                self.removeAction(forKey: "Selected")
                self.run(SKAction.colorize(withColorBlendFactor: 0.0, duration:0.15))
                guard let scene = self.scene as? GameScene else {return}
                scene.unitSelection.showNothing()
            }
        }
    }
    
    var nextAction: Action = .idle
    var nextDirection: Direction = .down
    
    var positionInMap:[Int] = [0,0] {
        didSet {
            guard let scene = self.scene as? GameScene else {return}
            if self.index == scene.localPlayer!.index {
                updateFog(newPosition: positionInMap, oldPosition: oldValue)
            }
        }
    }
    var nextPositionInMap:[Int] = [0,0] {
        didSet {
            guard let scene = self.scene as? GameScene else {return}
            if nextPositionInMap != oldValue {
                scene.gridGraph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(oldValue[0]),Int32(oldValue[1]))))
                scene.gridGraph.remove([GKGridGraphNode(gridPosition: vector_int2(Int32(self.nextPositionInMap[0]),Int32(self.nextPositionInMap[1])))])
            }
        }
    }
    var locationInMap:[Int] = [0,0] // [column,row]
    var fastestPathToLocation:[CGPoint]?
    
    
    
    var direction:Direction = .down {
        didSet {
            setSprite(direction)
        }
    }
    
    var action: Action = .idle {
        didSet {
            setSprite(direction)
        }
    }
    
    // MARK: - INITS
    
    init(race: Race ,positionInMap: [Int], index: PlayerType) {
        self.race = race
        self.index = index
        super.init(texture: SKTexture(imageNamed:"peonIdle1",filter: .nearest), color: UIColor.red, size: CGSize(width: 32, height: 32))
        self.zPosition = 1
        self.name = "Units"
        self.positionInMap = positionInMap
        self.nextPositionInMap = positionInMap
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
    
    
    
    
    
    // MARK: - ANIMATION
    
    func update() {
        action = nextAction
        direction = nextDirection
        nextAction = .idle
        nextDirection = .down
    }
    
    private func setSprite(_ direction: Direction) {
        if action == .idle {
            self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "1",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "2",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "3",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "4",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "5",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "6",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "7",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "8",filter: .nearest)], timePerFrame: 0.2)),withKey: "ANIM1")
        } else {
            self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "1",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "2",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "3",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "4",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "5",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "6",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "7",filter: .nearest),SKTexture(imageNamed: "\(unitName)" + "\(action)".capitalized + "\(direction)".capitalized + "8",filter: .nearest)], timePerFrame: 0.1)),withKey: "ANIM2")
        }
    }
    
    private func showLife() {
        self.enumerateChildNodes(withName: "LIFEBAR") {
            (node:SKNode, nil) in
            let lifeBar = node as! SKShapeNode
            lifeBar.removeFromParent()
        }
        
        let maxWidth = 28
        let width = self.life*maxWidth/self.maxLife
        guard width >= 0 else {return}
        let rect = CGRect(origin: CGPoint(x: -maxWidth/2, y: -2), size: CGSize(width: width, height: 4))
        let lifeBar = SKShapeNode(rect: rect)
        lifeBar.fillColor = UIColor(red: 150/255, green: 25/255, blue: 21/255, alpha: 1)
        lifeBar.name = "LIFEBAR"
        lifeBar.lineWidth = 0
        self.addChild(lifeBar)
        lifeBar.position = CGPoint(x: 0, y: 21)
        lifeBar.run(SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.run {
            lifeBar.removeFromParent()
        }]))
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
    
    
    
    func updateFog(newPosition: [Int], oldPosition: [Int]) {
        guard let scene = self.scene as? GameScene else {return}
        
        let columnDifference = newPosition[0]-oldPosition[0]
        let rowDifference = newPosition[1]-oldPosition[1]
        if abs(columnDifference) == 1 {
            for i in -discoveryRadius...discoveryRadius {
                
                let discoveredTile = [newPosition[0]+columnDifference*(discoveryRadius-abs(i)),newPosition[1]+i]
                
                scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "None"}, forColumn: newPosition[0]+columnDifference*(discoveryRadius-abs(i)), row: newPosition[1]+i)
                
                if let index = scene.fog.visibleTiles.firstIndex(of: discoveredTile) {
                    scene.fog.viewers[index] += 1
                } else {
                    scene.fog.visibleTiles.append(discoveredTile)
                    scene.fog.viewers.append(1)
                }
                
                let undiscoveredTile = [oldPosition[0]-columnDifference*(discoveryRadius-abs(i)),oldPosition[1]+i]
                if let index = scene.fog.visibleTiles.firstIndex(of: undiscoveredTile) {
                    scene.fog.viewers[index] -= 1
                    if scene.fog.viewers[index] <= 0 {
                        scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "Fog4"}, forColumn: oldPosition[0]-columnDifference*(discoveryRadius-abs(i)), row: oldPosition[1]+i)
                    }
                }
            }
        } else if abs(rowDifference) == 1 {
            for i in -discoveryRadius...discoveryRadius {
                scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "None"}, forColumn: newPosition[0]+i, row: newPosition[1]+rowDifference*(discoveryRadius-abs(i)))
                
                let discoveredTile = [newPosition[0]+i,newPosition[1]+rowDifference*(discoveryRadius-abs(i))]
                
                if let index = scene.fog.visibleTiles.firstIndex(of: discoveredTile) {
                    scene.fog.viewers[index] += 1
                } else {
                    scene.fog.visibleTiles.append(discoveredTile)
                    scene.fog.viewers.append(1)
                }
                
                let undiscoveredTile = [oldPosition[0]+i,oldPosition[1]-rowDifference*(discoveryRadius-abs(i))]
                if let index = scene.fog.visibleTiles.firstIndex(of: undiscoveredTile) {
                    scene.fog.viewers[index] -= 1
                    
                    if scene.fog.viewers[index] <= 0 {
                        scene.fog.fogLayer.setTileGroup(scene.fog.fogLayer.tileSet.tileGroups.first {$0.name == "Fog4"}, forColumn: oldPosition[0]+i, row: oldPosition[1]-rowDifference*(discoveryRadius-abs(i)))
                    }
                }
                
            }
        }
    }
    
    
    // MARK: - DO ACTIONS
    
    func doAction(row: Int, column: Int) {
        if let unit = checkIfUnits(row: row, column: column), unit.index != self.index {
            print("there's an unit")
            tryAttacking(node: unit)
        } else if let building = checkIfEnemyBuilding(row: row, column: column) {
            tryAttacking(node: building)
        } else {
            tryToMoveToLocation(row: row, column: column)
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(CGFloat(self.fastestPathToLocation!.count-1)*32.0/celerity)+0.1),SKAction.run {
                self.checkEnemiesAroundMe(radius: 2 + self.range)
            }]))
        }
    }
    
    func die() {
        guard let scene = self.scene as? GameScene else {return}
        self.removeAllActions()
        let deadAnimation = SKSpriteNode(imageNamed: "\(self.race)" + "\(self.unitType)".capitalized + "Die1")
        deadAnimation.size = self.size
        deadAnimation.zPosition = 1
        scene.map.addChild(deadAnimation)
        deadAnimation.position = self.position
        self.removeFromParent()
        deadAnimation.run(SKAction.animate(with: [SKTexture(imageNamed:  "\(self.race)" + "\(self.unitType)".capitalized + "Die1", filter: .nearest),SKTexture(imageNamed: "\(self.race)" + "\(self.unitType)".capitalized + "Die2", filter: .nearest),SKTexture(imageNamed: "\(self.race)" + "\(self.unitType)".capitalized + "Die3", filter: .nearest),SKTexture(imageNamed: "\(self.race)" + "\(self.unitType)".capitalized + "Die4", filter: .nearest)], timePerFrame: 0.2),completion: {
            scene.gridGraph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(self.nextPositionInMap[0]),Int32(self.nextPositionInMap[1]))))
            deadAnimation.removeFromParent()
        })
    }
    
    // MARK: - ATTACK
    
    func tryAttacking(node: SKNode) {
        guard let scene = self.scene as? GameScene else {return}
        guard node.parent == scene.map else {
            if self.action == .walk {
                let nextPosition = scene.mapLayer?.centerOfTile(atColumn: nextPositionInMap[0], row: nextPositionInMap[1])
                self.setSprite(self.direction)
                let xCoordinate: CGFloat = nextPosition!.x - self.position.x
                let yCoordinate: CGFloat = nextPosition!.y - self.position.y
                let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate)
                self.run(SKAction.move(to: nextPosition!, duration: TimeInterval(distance/self.celerity)), completion: {
                    self.removeAllActions()
                    self.action = .idle
                    self.positionInMap = self.nextPositionInMap
                    self.checkEnemiesAroundMe(radius : 2 + self.range)
                })
            } else {
                self.removeAllActions()
                self.action = .idle
                self.checkEnemiesAroundMe(radius: 2 + self.range)
            }
            return}
        
        
        if let unit = node as? Units {
            let columnDifference = abs(self.positionInMap[0] - unit.positionInMap[0])
            let rowDifference = abs(self.positionInMap[1] - unit.positionInMap[1])
            if (columnDifference+rowDifference)*32 <= range*32 {
                if self.action == .walk {
                    let nextPosition = scene.mapLayer?.centerOfTile(atColumn: nextPositionInMap[0], row: nextPositionInMap[1])
                    self.setSprite(self.direction)
                    let xCoordinate: CGFloat = nextPosition!.x - self.position.x
                    let yCoordinate: CGFloat = nextPosition!.y - self.position.y
                    let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate)
                    self.run(SKAction.move(to: nextPosition!, duration: TimeInterval(distance/self.celerity)), completion: {
                        self.removeAllActions()
                        self.action = .idle
                        self.positionInMap = self.nextPositionInMap
                        self.tryAttacking(node: unit)
                    })
                } else if self.action == .idle || self.action == .attack {
                    self.removeAllActions()
                    self.action = .attack
                    if self.positionInMap[1]-unit.positionInMap[1] < 0 {
                        self.direction = .up
                    } else {
                        self.direction = self.positionInMap[0]-unit.positionInMap[0] > 0 ? .left : .right
                    }
                    self.run(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run {
                        unit.life -= 1
                        self.removeAllActions()
                        self.tryAttacking(node: unit)
                    }]))
                }
            } else {
                let position = unit.nextPositionInMap
                guard let scene = self.scene as? GameScene else {return}
                let tile1 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]),Int32(position[1]-1)))
                let tile2 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]),Int32(position[1]+1)))
                let tile3 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]+1),Int32(position[1])))
                let tile4 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]-1),Int32(position[1])))
                
                guard tile1 != nil || tile2 != nil || tile3 != nil || tile4 != nil else {
                    self.removeAllActions()
                    self.action = .idle
                    self.checkEnemiesAroundMe(radius: 2 + self.range)
                    return}
                tryToMoveToLocation(row: position[1], column: position[0])
                
                self.run(SKAction.wait(forDuration: 1.8),completion: {
                    self.removeAllActions()
                    self.tryAttacking(node: unit)
                })
            }
        } else if let building = node as? Buildings {
            let columnDifference = abs(self.positionInMap[0] - building.positionInMap[0])
            let rowDifference = abs(self.positionInMap[1] - building.positionInMap[1])
            if (columnDifference+rowDifference)*32 <= range*32 {
                if self.action == .walk {
                    let nextPosition = scene.mapLayer?.centerOfTile(atColumn: nextPositionInMap[0], row: nextPositionInMap[1])
                    self.setSprite(self.direction)
                    let xCoordinate: CGFloat = nextPosition!.x - self.position.x
                    let yCoordinate: CGFloat = nextPosition!.y - self.position.y
                    let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate)
                    self.run(SKAction.move(to: nextPosition!, duration: TimeInterval(distance/self.celerity)), completion: {
                        self.removeAllActions()
                        self.action = .idle
                        self.positionInMap = self.nextPositionInMap
                        self.tryAttacking(node: building)
                    })
                } else if self.action == .idle || self.action == .attack {
                    self.removeAllActions()
                    self.action = .attack
                    if self.positionInMap[1]-building.positionInMap[1] < 0 {
                        self.direction = .up
                    } else {
                        self.direction = self.positionInMap[0]-building.positionInMap[0] > 0 ? .left : .right
                    }
                    self.run(SKAction.sequence([SKAction.wait(forDuration: 0.8),SKAction.run {
                        building.life -= 1
                        scene.smallMessage.position = building.positionInMap
                        scene.smallMessage.life = building.life
                        scene.sendSmallInfo()
                        self.removeAllActions()
                        self.tryAttacking(node: building)
                    }]))
                }
            } else {
                let position = building.positionInMap
                guard let scene = self.scene as? GameScene else {return}
                let tile1 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]),Int32(position[1]-1)))
                let tile2 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]),Int32(position[1]+1)))
                let tile3 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]+1),Int32(position[1])))
                let tile4 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(position[0]-1),Int32(position[1])))
                
                guard tile1 != nil || tile2 != nil || tile3 != nil || tile4 != nil else {
                    self.removeAllActions()
                    self.action = .idle
                    self.checkEnemiesAroundMe(radius: 2 + self.range)
                    return}
                tryToMoveToLocation(row: position[1], column: position[0])
                
                self.run(SKAction.wait(forDuration: 1.8),completion: {
                    self.removeAllActions()
                    self.tryAttacking(node: building)
                })
            }
        }
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
                let tile1 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(unit.nextPositionInMap[0]),Int32(unit.nextPositionInMap[1]-1)))
                let tile2 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(unit.nextPositionInMap[0]),Int32(unit.nextPositionInMap[1]+1)))
                let tile3 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(unit.nextPositionInMap[0]+1),Int32(unit.nextPositionInMap[1])))
                let tile4 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(unit.nextPositionInMap[0]-1),Int32(unit.nextPositionInMap[1])))
                if tile1 != nil || tile2 != nil || tile3 != nil || tile4 != nil {
                    return unit
                } else {
                    return nil
                }
            } else {
                return unit
            }
        } else {
            return nil
        }
    }
    
    func checkIfEnemyBuilding(row: Int, column: Int) -> Buildings? {
        guard let scene = self.scene as? GameScene else {return nil}
        let nodesTouched = scene.map.nodes(at: (scene.mapLayer?.centerOfTile(atColumn: column, row: row))!)
        if let building = nodesTouched.first(where: {$0.zPosition == 1}) as? Buildings {
            if building.index != self.index {
                let tile1 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(building.positionInMap[0]),Int32(building.positionInMap[1]-1)))
                let tile2 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(building.positionInMap[0]),Int32(building.positionInMap[1]+1)))
                let tile3 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(building.positionInMap[0]+1),Int32(building.positionInMap[1])))
                let tile4 = scene.gridGraph.node(atGridPosition: vector_int2(Int32(building.positionInMap[0]-1),Int32(building.positionInMap[1])))
                if tile1 != nil || tile2 != nil || tile3 != nil || tile4 != nil {
                    return building
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    func checkEnemiesAroundMe(radius: Int) {
        for k in 1...radius {
            for i in -k...k {
                if abs(i) == k {
                    if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]), unit.index != self.index {
                        self.removeAllActions()
                        tryAttacking(node: unit)
                        return
                    }
                } else {
                    if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]-k+abs(i)), unit.index != self.index {
                        self.removeAllActions()
                        tryAttacking(node: unit)
                        return
                    }
                    if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]+k-abs(i)), unit.index != self.index {
                        self.removeAllActions()
                        tryAttacking(node: unit)
                        return
                    }
                }
            }
        }
    }
    
    func callAlliesAroundMe() {
        for k in 1...6 {
            for i in -k...k {
                if abs(i) == k {
                    if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]), unit.index == self.index, unit.action == .idle, unit != self {
                        unit.checkEnemiesAroundMe(radius: 4 + unit.range)
                    }
                } else {
                    if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]-k+abs(i)), unit.index == self.index, unit.action == .idle, unit != self {
                        unit.checkEnemiesAroundMe(radius: 4 + unit.range)
                    }
                    if let unit = checkIfUnits(row: positionInMap[1]+i, column: positionInMap[0]+k-abs(i)), unit.index == self.index, unit.action == .idle, unit != self {
                        unit.checkEnemiesAroundMe(radius: 4 + unit.range)
                    }
                }
            }
        }
    }
    
    


    
    // MARK: - MOVEMENT
    
    
    func tryToMoveToLocation(row:Int,column: Int) {
        locationInMap = [column,row]
        moveToLocation(row: row, column: column)
        
        
    }
    
    func moveToLocation(row: Int, column: Int) {
        // Fonction très complexe donc commenté, le principe est simple, elle trouve le chemin le plus accessible vers la localisation précisé et s'y rend. Si la localisation est indisponible, elle cherche le point disponible le plus proche de la localisation initiale et recommence. En même temps, elle rend les tiles en dessous des unités indisponible. Lorsqu'une unité entame une marche, le prochain tile de marche est rendu indisponible, tandis que le précèdent est rendu disponible.
        guard let scene = self.scene as? GameScene else {return}
        let positionRow = positionInMap[1]
        let positionColumn = positionInMap[0]
        let nextPosition = scene.mapLayer?.centerOfTile(atColumn: nextPositionInMap[0], row: nextPositionInMap[1])
        if self.action == .walk {
            // Si on était en marche, cela signifie qu'on a avorté le mouvement précédent et engagé un nouveau, on termine donc le dernier mouvement en s'y rendant puis on rappelle la fonction.
            self.setSprite(self.direction)
            let xCoordinate: CGFloat = nextPosition!.x - self.position.x
            let yCoordinate: CGFloat = nextPosition!.y - self.position.y
            let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate)
            self.run(SKAction.move(to: nextPosition!, duration: TimeInterval(distance/self.celerity)), completion: {
                self.action = .idle
                self.positionInMap = self.nextPositionInMap
                self.moveToLocation(row: row, column: column)
            })
        } else {
            // Si on ne faisait rien, on rajoute le tile où on est pour calculer le trajet
            scene.gridGraph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(positionColumn),Int32(positionRow))))
            let positionNode = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionColumn),Int32(positionRow)))!
            
            // On check que l'endroit d'arrivé est accessible sinon on cherche la localisation la plus proche de notre destination initiale
            guard let locationNode = scene.gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row))) else {
                scene.gridGraph.remove([GKGridGraphNode(gridPosition: vector_int2(Int32(positionColumn),Int32(positionRow)))])
                let arrayOfAvailableTiles = findNearestAvailableTilesFrom(positionInMap: locationInMap)
                let newLocation = findTheNearestTileFromMe(Tiles: arrayOfAvailableTiles)
                self.moveToLocation(row: newLocation[1], column: newLocation[0])
                return
            }
            // Si il est disponible, on calcule le trajet puis on retire le tile où on est ( on l'a remis juste pour le calcul )
            let GKPath = scene.gridGraph.findPath(from: positionNode, to: locationNode) as! [GKGridGraphNode]
            if positionInMap == nextPositionInMap {
                scene.gridGraph.remove([GKGridGraphNode(gridPosition: vector_int2(Int32(positionColumn),Int32(positionRow)))])
            }
            let path = createThePath(GKPath: GKPath) // On crée alors un chemin qui donne les positions TILE PAR TILE et on se met à marcher
            self.fastestPathToLocation = path
            self.action = .walk
            // Ensuite on appelle la fonction suivre le chemin.
            self.followThePath(path: path, tileInPath: 0)
        }
    }
    
    
    
    
    
    
    
    private func createThePath(GKPath: [GKGridGraphNode]) -> [CGPoint] {
        guard let scene = self.scene as? GameScene else {return [CGPoint]()}
        var path = [CGPoint]()
        for i in 0..<GKPath.count {
            let column = Int(GKPath[i].gridPosition[0])
            let row = Int(GKPath[i].gridPosition[1])
            let location = scene.mapLayer!.centerOfTile(atColumn: column, row: row)
            path.append(location)
        }
        return path
    }
    
    
    
    
    
    
    
    
    private func followThePath(path: [CGPoint], tileInPath: Int) {
        guard let scene = self.scene as? GameScene else {return}
        if tileInPath+1 == path.count {
            // Si on est au bout du chemin ou qu'il n'y a pas de chemin, on s'arrête et on s'update au cas où une autre action est attendu (ex: couper un arbre)
            self.action = .idle
            self.update()
            return
        } else if path.count == 0 {
            self.removeAllActions()
            self.action = .idle
            if failCounter < 5 {
                self.run(SKAction.sequence([SKAction.wait(forDuration: Double(1)+0.1),SKAction.run {
                    self.removeAllActions()
                    self.failCounter += 1
                    print("Il fou rien mais réessaye")
                    self.doAction(row: self.locationInMap[1], column: self.locationInMap[0])
                }]))
                return
            } else {
                self.removeAllActions()
                self.action = .idle
                print("I failed")
                failCounter = 0
                return
            }
        }
        failCounter = 0
        let xCoordinate: CGFloat = path[tileInPath+1].x - self.position.x
        let yCoordinate: CGFloat = path[tileInPath+1].y - self.position.y
        let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate) // On setup sa direction en fonction du prochain tile où se rendre
        if abs(xCoordinate) > abs(yCoordinate) {
            let newDirection: Direction = xCoordinate >= 0 ? .right : .left
            if newDirection != direction {
                direction = newDirection
            }
        } else {
            let newDirection: Direction = yCoordinate >= 0 ? .up : .down
            if newDirection != direction {
                direction = newDirection
            }
        }
        let nextRow = scene.mapLayer?.tileRowIndex(fromPosition: path[tileInPath+1])
        let nextColumn = scene.mapLayer?.tileColumnIndex(fromPosition: path[tileInPath+1])
        
        // On regarde si le tile où on doit se rendre est disponible, s'il ne l'est pas, il faut recalculer un trajet donc on appelle de nouveau moveToLocation avec la destination accessible qu'on avait trouvé
        guard let _ = scene.gridGraph.node(atGridPosition: vector_int2(Int32(nextColumn!),Int32(nextRow!))) else {
            self.doAction(row: self.locationInMap[1], column: self.locationInMap[0])
            return
        }
        
        guard let _ = scene.gridGraph.node(atGridPosition: vector_int2(Int32((scene.mapLayer?.tileColumnIndex(fromPosition: path[path.count-1]))!),Int32((scene.mapLayer?.tileRowIndex(fromPosition: path[path.count-1]))!))) else {
            self.doAction(row: self.locationInMap[1], column: self.locationInMap[0])
            return
        }
        
        
        // Si il est dispo, on le retire et on remet l'ancien puis on s'y rend
        nextPositionInMap = [nextColumn!,nextRow!]
        self.run(SKAction.move(to: path[tileInPath+1], duration: TimeInterval(distance/self.celerity)), completion: {
            self.run(SKAction.run {
                // au moment d'arriver, on update sa position puis on rappelle la fonction avec le même chemin mais un tile plus loin
                self.positionInMap = [nextColumn!,nextRow!]
                self.followThePath(path: path, tileInPath: tileInPath+1)
            })
        })
    }
 
 
    
    func findTheNearestTileFromMe(Tiles: [[Int]]) -> [Int] {
        // Fonction qui trouve le tile disponible le plus proche de moi parmi une liste donné
        guard let scene = self.scene as? GameScene else {return []}
        let xCoordinate: CGFloat = (scene.mapLayer?.centerOfTile(atColumn: Tiles[0][0], row: Tiles[0][1]).x)! - self.position.x
        let yCoordinate: CGFloat = (scene.mapLayer?.centerOfTile(atColumn: Tiles[0][0], row: Tiles[0][1]).y)! - self.position.y
        let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate)
        var nearestTile = [Tiles[0][0],Tiles[0][1]]
        var minDistance = distance
        for i in 1..<Tiles.count {
            let xCoordinate: CGFloat = (scene.mapLayer?.centerOfTile(atColumn: Tiles[i][0], row: Tiles[i][1]).x)! - self.position.x
            let yCoordinate: CGFloat = (scene.mapLayer?.centerOfTile(atColumn: Tiles[i][0], row: Tiles[i][1]).y)! - self.position.y
            let distance = sqrt(xCoordinate*xCoordinate + yCoordinate*yCoordinate)
            if distance < minDistance {
                minDistance = distance
                nearestTile = [Tiles[i][0],Tiles[i][1]]
            }
        }
        return nearestTile
    }
    
    
    
    func findNearestAvailableTilesFrom(positionInMap: [Int]) -> [[Int]] {
        guard let scene = self.scene as? GameScene else {return []}
        var minDistance: CGFloat = 100000
        var nearestDistanceTiles = [[Int]]()
        for k in 0..<64 {
            for i in -k...k {
                for j in (-k+abs(i))...(k-abs(i)) {
                    if let _ = scene.gridGraph.node(atGridPosition: vector_int2(Int32(positionInMap[0]+j),Int32(positionInMap[1]+i))) {
                        let xCoordinate = (scene.mapLayer?.centerOfTile(atColumn: positionInMap[0], row: positionInMap[1]).x)!-(scene.mapLayer?.centerOfTile(atColumn: positionInMap[0]+j, row: positionInMap[1]+i).x)!
                        let yCoordinate = (scene.mapLayer?.centerOfTile(atColumn: positionInMap[0], row: positionInMap[1]).y)!-(scene.mapLayer?.centerOfTile(atColumn: positionInMap[0]+j, row: positionInMap[1]+i).y)!
                        let distance = sqrt(xCoordinate*xCoordinate+yCoordinate*yCoordinate)
                        if distance < minDistance {
                            minDistance = distance
                            nearestDistanceTiles = [[positionInMap[0]+j, positionInMap[1]+i]]
                        } else if distance == minDistance {
                            nearestDistanceTiles.append([positionInMap[0]+j, positionInMap[1]+i])
                        }
                    }
                }
            }
            if nearestDistanceTiles.count > 0 {
                return nearestDistanceTiles
            } else {
                continue
            }
        }
        return [[]]
    }
}
