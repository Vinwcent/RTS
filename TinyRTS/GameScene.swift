//
//  GameScene.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 12/08/2021.
//

import SpriteKit
import GameKit

class GameScene: SKScene {
    
    // MARK: - WORKPLACE
    
    func workplace() {
        
        match?.delegate = self
        
        let testUnit = Peasant(race: gameModel.players[0].race, positionInMap: [15,15], index: gameModel.players[0].index)
        self.map.addChild(testUnit)
        testUnit.unitNumber = giveAnEntityNumber()
        testUnit.position = (self.mapLayer?.centerOfTile(atColumn: 15, row: 15))!
        testUnit.life = 4
        
        let soldierUnit = Soldier(race: gameModel.players[0].race, positionInMap: [12,12], index: gameModel.players[0].index)
        self.map.addChild(soldierUnit)
        soldierUnit.unitNumber = giveAnEntityNumber()
        soldierUnit.position = (self.mapLayer?.centerOfTile(atColumn: 12, row: 12))!
        
        let secondTestUnit = Peasant(race: gameModel.players[1].race, positionInMap: [6,6], index: gameModel.players[1].index)
        self.map.addChild(secondTestUnit)
        secondTestUnit.unitNumber = giveAnEntityNumber()
        secondTestUnit.position = (self.mapLayer?.centerOfTile(atColumn: 6, row: 6))!
        
        secondTestUnit.celerity = 512
        secondTestUnit.life = 10
        
    }
    
    
    // MARK: - GAMECENTER
    
    var match: GKMatch?
    var gameModel: GameModel!
    var smallMessage: SmallMessage!
    
    var increasingEntity: Int = 0
    
    func giveAnEntityNumber() -> Int {
        increasingEntity += 1
        return increasingEntity-1
    }
    
    
    // MARK: - VARS
    
    var tileSelector = SKSpriteNode(texture: SKTexture(imageNamed: "tileSelector1", filter: .nearest))
    var selectionRectangle = SKSpriteNode(color: UIColor.red , size: CGSize(width: 0, height: 0))
    var mapLayer: SKTileMapNode?
    var mapBackground: SKTileMapNode?
    var gridGraph = GKGridGraph(fromGridStartingAt: vector_int2(0,0), width: Int32(0), height: Int32(0), diagonalsAllowed: false)
    
    var localPlayer: Player?
    
    
    let map = SKNode()
    var mapScale: CGFloat = 1 {
        didSet {
            map.setScale(mapScale)
            map.position = self.view!.center
        }
    }
    
    var menuNode = Menu(race: .orc)
    var glass: SKSpriteNode!
    var descriptionNode = Description()
    var gui = Gui()
    var unitSelection = SelectedUnits()
    var fog = Fog()
    
    let environmentBitmask:UInt32 = 0x1 << 0
    let unitsBitmask:UInt32 = 0x1 << 1
    
    
    
    
    
    // MARK: - INITIALIZE
    
    func initializeTheGame() {
        setupTheMap()
        setupGesture()
        setupTheGameMenu()
        setupTileSelector()
        setupGlass()
        smallMessage = SmallMessage()
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1/20),SKAction.run {
            self.networkUpdate()
        }])))
    }
    
    
    func setupGesture() {
        let panScrollRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameScene.panScrolling(sender:)))
        panScrollRecognizer.minimumNumberOfTouches = 1
        panScrollRecognizer.maximumNumberOfTouches = 1
        self.view!.addGestureRecognizer(panScrollRecognizer)
        
        let panSelectRecognizer = ImmediatePGR(target: self, action: #selector(GameScene.panSelection(sender:)))
        panSelectRecognizer.minimumNumberOfTouches = 2
        panSelectRecognizer.maximumNumberOfTouches = 2
        self.view!.addGestureRecognizer(panSelectRecognizer)
        
        map.addChild(selectionRectangle)
    }
    
    // MARK: - PANS
    
    
    @objc func panScrolling(sender: UIPanGestureRecognizer ) {
        let mapWidth = mapLayer!.mapSize.width*mapScale
        if sender.state == .changed {
            let translation = sender.translation(in: sender.view!)
            if map.position.x + translation.x < mapWidth/2 && map.position.x + translation.x > -mapWidth/2 + self.view!.frame.width && map.position.y - translation.y < mapWidth/2 && map.position.y - translation.y > -mapWidth/2 + self.view!.frame.height {
                
                map.position = CGPoint(x: map.position.x+translation.x, y: map.position.y-translation.y)
                
            } else if map.position.x + translation.x < mapWidth/2 && map.position.x + translation.x > -mapWidth/2 + self.view!.frame.width {
                
                map.position = CGPoint(x: map.position.x+translation.x, y: map.position.y)
                
            } else if map.position.y - translation.y < mapWidth/2 && map.position.y - translation.y > -mapWidth/2 + self.view!.frame.height {
                
                map.position = CGPoint(x: map.position.x, y: map.position.y-translation.y)
                
            }
            sender.setTranslation(CGPoint.zero, in: sender.view!)
        }
    }
    
    @objc func panSelection(sender: UIPanGestureRecognizer) {
        guard !checkIfPlacing() else {return}
        switch sender.state {
        case .began:
            if sender.numberOfTouches > 1 {
                let firstTouch = sender.location(ofTouch: 0, in: self.view!)
                let secondTouch = sender.location(ofTouch: 1, in: self.view!)
                let width = abs(firstTouch.x - secondTouch.x)
                let height = abs(firstTouch.y - secondTouch.y)
                let Xcenter = (firstTouch.x + secondTouch.x)/2
                let Ycenter = (firstTouch.y + secondTouch.y)/2 // Car la frame d'une UIView est en haut à gauche tandis que celle de ma scène est en bas à droite
                let center = convert(convertPoint(fromView: CGPoint(x: Xcenter, y: Ycenter)), to: map)
                selectionRectangle.size = CGSize(width: width, height: height)
                selectionRectangle.size = CGSize(width: width, height: height)
                selectionRectangle.position = center
            }
        case .changed:
            if sender.numberOfTouches > 1 {
                let firstTouch = sender.location(ofTouch: 0, in: self.view!)
                let secondTouch = sender.location(ofTouch: 1, in: self.view!)
                let width = abs(firstTouch.x - secondTouch.x)
                let height = abs(firstTouch.y - secondTouch.y)
                let Xcenter = (firstTouch.x + secondTouch.x)/2
                let Ycenter = (firstTouch.y + secondTouch.y)/2 // Car la frame d'une UIView est en haut à gauche tandis que celle de ma scène est en bas à droite
                let center = convert(convertPoint(fromView: CGPoint(x: Xcenter, y: Ycenter)), to: map)
                selectionRectangle.size = CGSize(width: width, height: height)
                selectionRectangle.position = center
            }
        case .ended:
            let minX = self.selectionRectangle.frame.minX
            let maxX = self.selectionRectangle.frame.maxX
            let minY = self.selectionRectangle.frame.minY
            let maxY = self.selectionRectangle.frame.maxY
            var amountSelected:Int = 0
            map.enumerateChildNodes(withName: "Units") {
                (node:SKNode, nil) in
                let unit = node as! Units
                guard unit.race == self.localPlayer!.race else {return}
                unit.isSelected = false
                if node.position.x >= minX && node.position.x <= maxX && node.position.y >= minY && node.position.y <= maxY {
                    if amountSelected < 6 {
                        unit.isSelected = true
                        amountSelected += 1
                    }
                }
            }
            if amountSelected == 1 {
                map.enumerateChildNodes(withName: "Units") {
                    (node:SKNode, nil) in
                    let unit = node as! Units
                    self.menuNode.showTheUnitMenu(unit: unit)
                }
            }
            selectionRectangle.size = CGSize(width: 0, height: 0)
            unitSelection.showSelectedUnits(amount: amountSelected)
            menuNode.showEmptyMenu()
        default:
            return
        }
    }
    
    // MARK: - OVERRIDES
    
    override func didMove(to view: SKView) {
        
        initializeTheGame()
        workplace()
        fog.initializeTheFog()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func networkUpdate() {
        if localPlayer!.index == .one {
            gameModel.buildingPositionArray = []
            gameModel.buildingTypeArray = []
            gameModel.builtPercentageArray = []
            
            gameModel.unitTypeArray = []
            gameModel.positionArray = []
            gameModel.actionArray = []
            gameModel.directionArray = []
            gameModel.nextPositionInMapArray = []
            gameModel.positionInMapArray = []
            
            gameModel.enemyLifeArray = []
            map.enumerateChildNodes(withName: "Units") {
                (node:SKNode, nil) in
                let unit = node as? Units
                if unit!.index == .one {
                    self.gameModel.unitTypeArray.append(unit!.unitType)
                    self.gameModel.positionArray.append(unit!.position)
                    self.gameModel.actionArray.append(unit!.action)
                    self.gameModel.directionArray.append(unit!.direction)
                    self.gameModel.nextPositionInMapArray.append(unit!.nextPositionInMap)
                    self.gameModel.positionInMapArray.append(unit!.positionInMap)
                } else {
                    self.gameModel.enemyLifeArray.append(unit!.life)
                }
            }
            
            map.enumerateChildNodes(withName: "Buildings") {
                (node:SKNode, nil) in
                let building = node as? Buildings
                if building!.index == .one && building!.alpha == 1 {
                    self.gameModel.buildingPositionArray.append(building!.position)
                    self.gameModel.buildingTypeArray.append(building!.buildingType)
                    self.gameModel.builtPercentageArray.append(building!.builtPercentage)
                }
            }
        } else {
            gameModel.buildingPositionArray2 = []
            gameModel.buildingTypeArray2 = []
            gameModel.builtPercentageArray2 = []
            
            gameModel.unitTypeArray2 = []
            gameModel.positionArray2 = []
            gameModel.actionArray2 = []
            gameModel.directionArray2 = []
            gameModel.nextPositionInMapArray2 = []
            gameModel.positionInMapArray2 = []
            
            gameModel.enemyLifeArray2 = []
            map.enumerateChildNodes(withName: "Units") {
                (node:SKNode, nil) in
                let unit = node as? Units
                if unit!.index == .two {
                    self.gameModel.unitTypeArray2.append(unit!.unitType)
                    self.gameModel.positionArray2.append(unit!.position)
                    self.gameModel.actionArray2.append(unit!.action)
                    self.gameModel.directionArray2.append(unit!.direction)
                    self.gameModel.nextPositionInMapArray2.append(unit!.nextPositionInMap)
                    self.gameModel.positionInMapArray2.append(unit!.positionInMap)
                } else {
                    self.gameModel.enemyLifeArray2.append(unit!.life)
                }
            }
            
            map.enumerateChildNodes(withName: "Buildings") {
                (node:SKNode, nil) in
                let building = node as? Buildings
                if building!.index == .two && building!.alpha == 1 {
                    self.gameModel.buildingPositionArray2.append(building!.position)
                    self.gameModel.buildingTypeArray2.append(building!.buildingType)
                    self.gameModel.builtPercentageArray2.append(building!.builtPercentage)
                }
            }
            
        }
        self.sendData()
    }

    
    
    
    // MARK: - TOUCHES
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            var touchPosition = touch.location(in: self)
            let nodesTouched = self.nodes(at: touchPosition)
            var nodeTouched = SKNode()
            for i in 0..<nodesTouched.count-1 {
                if nodesTouched[i].zPosition == 1 {
                    nodeTouched = nodesTouched[i]
                }
            }
            if nodesTouched.contains(glass) {
                self.rescaleMap()
                glass.removeAllActions()
                glass.run(SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 0.1),SKAction.fadeAlpha(to: 0.3, duration: 0.1)]))
            } else if nodesTouched.contains(menuNode.menuLayer) {
                // MARK: - Menu
                let location = touch.location(in: menuNode)
                menuNode.checkWhichNodeIsTouched(location: location)
            } else {
                // MARK: - Autres que Menu
                if checkIfPlacing() {
                    
                    
                    // MARK: - En placement
                    map.enumerateChildNodes(withName: "Buildings") {
                        (node: SKNode, nil) in
                        let building = node as! Buildings
                        if building.isBeingPlaced {
                            touchPosition = touch.location(in: self.map)
                            let row = self.mapLayer?.tileRowIndex(fromPosition: touchPosition)
                            let column = self.mapLayer?.tileColumnIndex(fromPosition: touchPosition)
                            building.position = (self.mapLayer?.centerOfTile(atColumn: column!, row: row!))!
                            self.moveTheTileSelector(row: row!, column: column!)
                        }
                    }
                } else {
                    // MARK: - Pas en placement
                    touchPosition = touch.location(in: self.map)
                    let row = self.mapLayer?.tileRowIndex(fromPosition: touchPosition)
                    let column = self.mapLayer?.tileColumnIndex(fromPosition: touchPosition)
                    self.moveTheTileSelector(row: row!, column: column!)
                    if let building = nodeTouched as? Buildings, building.index == self.localPlayer!.index {
                        // MARK: - Touche batîment
                        if building.index == localPlayer!.index && building.builtPercentage >= 100 {
                            map.enumerateChildNodes(withName: "Buildings") {
                                (node:SKNode, nil) in
                                let building = node as! Buildings
                                if building.index == self.localPlayer!.index {
                                    building.isSelected = false
                                }
                            }
                            map.enumerateChildNodes(withName: "Units") {
                                (node:SKNode, nil) in
                                let unit = node as! Units
                                if unit.isSelected {
                                    unit.isSelected = false
                                }
                            }
                            
                            
                            building.isSelected = true
                            menuNode.showTheBuildingMenu(building: building)
                        } else {
                            map.enumerateChildNodes(withName: "Units") {
                                (node:SKNode, nil) in
                                let unit = node as! Units
                                if let peasant = unit as? Peasant {
                                    if peasant.isSelected {
                                        peasant.isSelected = false
                                        peasant.buildTheBuilding(building: building)
                                    }
                                }
                            }
                        }
                    } else if let unitTouched = nodeTouched as? Units, unitTouched.index == localPlayer!.index {
                        // MARK: - Touche unité
                        map.enumerateChildNodes(withName: "Units") {
                            (node:SKNode, nil) in
                            let unit = node as! Units
                            if unit.isSelected {
                                unit.isSelected = false
                            }
                        }
                        menuNode.showTheUnitMenu(unit: unitTouched)
                        unitTouched.isSelected = true
                        unitSelection.showSelectedUnits(amount: 1)
                    } else {
                        // MARK: - Touche sol
                        map.enumerateChildNodes(withName: "Units") {
                            (node:SKNode, nil) in
                            let unit = node as! Units
                            guard unit.index == self.localPlayer!.index else {return}
                            if unit.isSelected {
                                unit.removeAllActions()
                                unit.doAction(row: row!, column: column!)
                                unit.isSelected = false
                            }
                        }
                        map.enumerateChildNodes(withName: "Buildings") {
                            (node:SKNode, nil) in
                            let building = node as? Buildings
                            building?.isSelected = false
                        }
                        menuNode.showEmptyMenu()
                    }
                }
            }
        }
    }
    
    func checkIfPlacing() -> Bool {
        var bool = false
        map.enumerateChildNodes(withName: "Buildings") {
            (node:SKNode, nil) in
            let building = node as? Buildings
            if (building?.isBeingPlaced)! {
                bool = true
            }
        }
        return bool
    }
    
}
