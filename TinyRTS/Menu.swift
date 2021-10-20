//
//  Menu.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 15/08/2021.
//

import SpriteKit
import GameplayKit

class Menu: SKSpriteNode {
    
    
    let tileSize = CGSize(width: 52, height: 52)
    let columns = 5
    let rows = 2
    var menuLayer: SKTileMapNode
    var race: Race
    
    init(race: Race) {
        self.race = race
        
        let tileSet =  SKTileSet(named: "Menu")!
        menuLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        
        super.init(texture: SKTexture(imageNamed: "menu", filter: .nearest), color: UIColor.red, size: CGSize(width: 304, height: 148))
        
        
        self.addChild(menuLayer)
        menuLayer.position = CGPoint(x: 6, y: 6)
        self.showEmptyMenu()
        self.zPosition = 6
        menuLayer.zPosition = 7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showEmptyMenu() {
        self.isHidden = true
        if let scene = self.scene as? GameScene {
            scene.descriptionNode.state = .none
        }
        let tileSet = menuLayer.tileSet
        for i in 0..<5 {
            for j in 0..<2 {
                menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Empty"}, forColumn: i, row: j)
            }
        }
    }
    
    func showThePlacingMenu() {
        showEmptyMenu()
        self.isHidden = false
        let tileSet = menuLayer.tileSet
        menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Correct"}, forColumn: 3, row: 1)
        menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Wrong"}, forColumn: 4, row: 1)
    }
    
    func showTheUnitMenu(unit: Units) {
        guard let scene = self.scene as? GameScene else {return}
        showEmptyMenu()
        self.isHidden = false
        let tileSet = menuLayer.tileSet
        switch unit.unitType {
        case .peasant:
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Base"}, forColumn: 0, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Farm"}, forColumn: 1, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Barrack"}, forColumn: 3, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Supply"}, forColumn: 2, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Tower"}, forColumn: 4, row: 1)
            if scene.localPlayer?.race == .human {
                menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Windmill"}, forColumn: 0, row: 0)
            }
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Wrong"}, forColumn: 4, row: 0)
        case .soldier:
            showEmptyMenu()
        case .wolf:
            showEmptyMenu()
        case .ambassador:
            showEmptyMenu()
        case .archer:
            showEmptyMenu()
        case .wizard:
            showEmptyMenu()
        }
    }
    
    func showTheBuildingMenu(building: Buildings) {
        showEmptyMenu()
        self.isHidden = false
        let tileSet = menuLayer.tileSet
        switch building.buildingType {
        case .base:
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Peasant"}, forColumn: 0, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Wrong"}, forColumn: 4, row: 1)
        case .farm:
            showEmptyMenu()
        case .barrack:
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Soldier"}, forColumn: 0, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Tier2"}, forColumn: 1, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "\(self.race)".capitalized + "Tier3"}, forColumn: 2, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Wrong"}, forColumn: 4, row: 1)
        case .windmill:
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Wheat"}, forColumn: 0, row: 1)
            menuLayer.setTileGroup(tileSet.tileGroups.first {$0.name == "Wrong"}, forColumn: 4, row: 1)
        case .supply:
            showEmptyMenu()
        case .tower:
            showEmptyMenu()
        }
    }
    
    
    func checkWhichNodeIsTouched(location: CGPoint) {
        guard let scene = self.scene as? GameScene else {return}
        let row = self.menuLayer.tileRowIndex(fromPosition: location)
        let column = self.menuLayer.tileColumnIndex(fromPosition: location)
        guard let definition = menuLayer.tileDefinition(atColumn: column, row: row) else { return }
        guard let userData = definition.userData else { return }
        guard let typeAny = userData["type"] else { return }
        let type = typeAny as! String
        if type == "base" {
            Buildings.spawnBuildings(scene: self.scene as! GameScene, type: .base, index: scene.localPlayer!.index)
            scene.descriptionNode.state = .base
        } else if type == "farm" {
            Buildings.spawnBuildings(scene: self.scene as! GameScene, type: .farm, index: scene.localPlayer!.index)
            scene.descriptionNode.state = .farm
        } else if type == "barrack" {
            Buildings.spawnBuildings(scene: self.scene as! GameScene, type: .barrack, index: scene.localPlayer!.index)
            scene.descriptionNode.state = .barrack
        } else if type == "windmill" {
            Buildings.spawnBuildings(scene: self.scene as! GameScene, type: .windmill, index: scene.localPlayer!.index)
            scene.descriptionNode.state = .windmill
        } else if type == "supply" {
            Buildings.spawnBuildings(scene: self.scene as! GameScene, type: .supply, index: scene.localPlayer!.index)
            scene.descriptionNode.state = .supply
        } else if type == "tower" {
            Buildings.spawnBuildings(scene: self.scene as! GameScene, type: .tower, index: scene.localPlayer!.index)
            scene.descriptionNode.state = .tower
        } else if type == "correct" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                let building = node as? Buildings
                if building!.isBeingPlaced {
                    building!.isBeingPlaced = false
                    scene.map.enumerateChildNodes(withName: "Units") {
                        (node:SKNode, nil) in
                        if let peasant = node as? Peasant {
                            if peasant.isSelected {
                                peasant.removeAllActions()
                                let positionRow = scene.mapLayer?.tileRowIndex(fromPosition: building!.position)
                                let positionColumn = scene.mapLayer?.tileColumnIndex(fromPosition: building!.position)
                                peasant.goStartBuilding(building: building!, row: positionRow!, column: positionColumn!)
                                peasant.isSelected = false
                                self.showEmptyMenu()
                            }
                        }
                    }
                }
            }
        } else if type == "wrong" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                let building = node as? Buildings
                if building!.isBeingPlaced {
                    building?.removeFromParent()
                }
            }
            
            scene.map.enumerateChildNodes(withName: "Units") {
                (node: SKNode, nil) in
                let unit = node as? Units
                if unit?.index == scene.localPlayer?.index {
                    unit?.isSelected = false
                }
            }
            self.showEmptyMenu()
        } else if type == "peasant" {
            if scene.descriptionNode.state == .peasant  && checkPrice(type: .peasant) {
                scene.map.enumerateChildNodes(withName: "Buildings") { [self]
                    (node: SKNode, nil) in
                    if let base = node as? Base{
                        if base.isSelected {
                            self.removePrice(type: .peasant)
                            base.spawnAPeasant()
                        }
                    }
                }
            } else {
                scene.descriptionNode.state = .peasant
            }
        } else if type == "soldier" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                if let barrack = node as? Barrack {
                    if barrack.isSelected {
                        barrack.spawnASoldier()
                    }
                }
            }
        } else if type == "wolf" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                if let barrack = node as? Barrack {
                    if barrack.isSelected {
                        barrack.spawnAWolf()
                    }
                }
            }
        } else if type == "ambassador" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                if let barrack = node as? Barrack {
                    if barrack.isSelected {
                        barrack.spawnAnAmbassador()
                    }
                }
            }
        } else if type == "archer" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                if let barrack = node as? Barrack {
                    if barrack.isSelected {
                        barrack.spawnAnArcher()
                    }
                }
            }
        } else if type == "wizard" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                if let barrack = node as? Barrack {
                    if barrack.isSelected {
                        barrack.spawnAWizard()
                    }
                }
            }
        } else if type == "wheat" {
            scene.map.enumerateChildNodes(withName: "Buildings") {
                (node: SKNode, nil) in
                if let windmill = node as? Windmill {
                    if windmill.isSelected {
                        windmill.spawnWheat()
                        
                        scene.smallMessage.position = windmill.positionInMap
                        scene.sendSmallInfo()
                    }
                }
            }
        }
    }
    
    private func checkPrice(type: Description.State) -> Bool {
        guard let scene = self.scene as? GameScene else {return false}
        let race = scene.localPlayer!.race
        switch type {
        case .peasant:
            if race == .human {
                if Price.humanPeasant[0] <= scene.gui.amountOfWood && Price.humanPeasant[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            } else {
                if Price.orcPeasant[0] <= scene.gui.amountOfWood && Price.orcPeasant[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            }
        case .base:
            if race == .human {
                if Price.humanBase[0] <= scene.gui.amountOfWood && Price.humanBase[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            } else {
                if Price.orcBase[0] <= scene.gui.amountOfWood && Price.orcBase[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            }
        case .farm:
            if race == .human {
                if Price.humanFarm[0] <= scene.gui.amountOfWood && Price.humanFarm[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            } else {
                if Price.orcFarm[0] <= scene.gui.amountOfWood && Price.orcFarm[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            }
        case .windmill:
            if Price.windmill[0] <= scene.gui.amountOfWood && Price.windmill[1] <= scene.gui.amountOfGold {
                return true
            }
            return false
        case .barrack:
            if race == .human {
                if Price.humanBarrack[0] <= scene.gui.amountOfWood && Price.humanBarrack[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            } else {
                if Price.orcBarrack[0] <= scene.gui.amountOfWood && Price.orcBarrack[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            }
        case .none:
            return false
        case .supply:
            if race == .human {
                if Price.humanSupply[0] <= scene.gui.amountOfWood && Price.humanSupply[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            } else {
                if Price.orcSupply[0] <= scene.gui.amountOfWood && Price.orcSupply[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            }
        case .tower:
            if race == .human {
                if Price.humanTower[0] <= scene.gui.amountOfWood && Price.humanTower[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            } else {
                if Price.orcTower[0] <= scene.gui.amountOfWood && Price.orcTower[1] <= scene.gui.amountOfGold {
                    return true
                }
                return false
            }
        }
    }
    
    private func removePrice(type: Description.State) {
        guard let scene = self.scene as? GameScene else {return}
        let race = scene.localPlayer!.race
        switch type {
        case .peasant:
            if race == .human {
                scene.gui.amountOfWood -= Price.humanPeasant[0]
                scene.gui.amountOfGold -= Price.humanPeasant[1]
            } else {
                scene.gui.amountOfWood -= Price.orcPeasant[0]
                scene.gui.amountOfGold -= Price.orcPeasant[1]
            }
        case .base:
            if race == .human {
                scene.gui.amountOfWood -= Price.humanBase[0]
                scene.gui.amountOfGold -= Price.humanBase[1]
            } else {
                scene.gui.amountOfWood -= Price.orcBase[0]
                scene.gui.amountOfGold -= Price.orcBase[1]
            }
        case .farm:
            if race == .human {
                scene.gui.amountOfWood -= Price.humanFarm[0]
                scene.gui.amountOfGold -= Price.humanFarm[1]
            } else {
                scene.gui.amountOfWood -= Price.orcFarm[0]
                scene.gui.amountOfGold -= Price.orcFarm[1]
            }
        case .windmill:
            scene.gui.amountOfWood -= Price.windmill[0]
            scene.gui.amountOfGold -= Price.windmill[1]
        case .barrack:
            if race == .human {
                scene.gui.amountOfWood -= Price.humanBarrack[0]
                scene.gui.amountOfGold -= Price.humanBarrack[1]
            } else {
                scene.gui.amountOfWood -= Price.orcBarrack[0]
                scene.gui.amountOfGold -= Price.orcBarrack[1]
            }
        case .none:
            return
        case .supply:
            if race == .human {
                scene.gui.amountOfWood -= Price.humanSupply[0]
                scene.gui.amountOfGold -= Price.humanSupply[1]
            } else {
                scene.gui.amountOfWood -= Price.orcSupply[0]
                scene.gui.amountOfGold -= Price.orcSupply[1]
            }
        case .tower:
            if race == .human {
                scene.gui.amountOfWood -= Price.humanTower[0]
                scene.gui.amountOfGold -= Price.humanTower[1]
            } else {
                scene.gui.amountOfWood -= Price.orcTower[0]
                scene.gui.amountOfGold -= Price.orcTower[1]
            }
        }
    }
    
    
}
