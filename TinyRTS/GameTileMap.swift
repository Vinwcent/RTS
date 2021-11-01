//
//  GameTileMap.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 14/08/2021.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    
    // MARK: - MAP SETUP
    
    func setupTheMap() {
        self.addChild(map)
        map.xScale = 1
        map.yScale = 1
        map.position = self.view!.center
        
        let tileSet = SKTileSet(named: "MapTileSet")
        let tileSize = CGSize(width: 32, height: 32)
        let columns = 64
        let rows = 64
        
        let sceneBackground = self.childNode(withName: "map1Background")
        mapBackground = sceneBackground as? SKTileMapNode
        sceneBackground?.removeFromParent()
        map.addChild(mapBackground!)
        mapBackground!.position = CGPoint(x: 0, y: 0)
        
        let mapForeground = self.childNode(withName: "map1Foreground")
        mapLayer = mapForeground as? SKTileMapNode
        mapForeground?.removeFromParent()
        map.addChild(mapLayer!)
        mapLayer?.zPosition = 2
        mapLayer?.position = CGPoint(x: 0, y: 0)
        pixelArtMap()
        
        self.addChild(fog)
        
        gridGraph = GKGridGraph(fromGridStartingAt: vector_int2(0,0), width: Int32(columns), height: Int32(rows), diagonalsAllowed: false)
        
        setupGridGraph()
        setupTileNode()
        
    }

    private func setupTileNode() {
        for column in 0..<mapLayer!.numberOfColumns {
            for row in 0..<mapLayer!.numberOfRows {
                guard let definition = mapLayer!.tileDefinition(atColumn: column, row: row) else { continue }
                guard let userData = definition.userData else { continue }
                guard let typeAny = userData["type"] else { continue }
                let type = typeAny as! String
                if type == "forest" {
                    let location = mapLayer?.centerOfTile(atColumn: column, row: row)
                    let forestNode = Forest()
                    map.addChild(forestNode)
                    forestNode.position = location!
                } else if type == "mine" && definition.name == "goldMine1" {
                    let location = mapLayer?.centerOfTile(atColumn: column, row: row)
                    let mineNode = Mine()
                    map.addChild(mineNode)
                    mineNode.position = location!
                }
            }
        }
    }
    
    private func pixelArtMap() {
        let tileSet = mapLayer!.tileSet
        for tileGroup in tileSet.tileGroups {
            for tileRule in tileGroup.rules {
                for tileDefinition in tileRule.tileDefinitions {
                    tileDefinition.size = CGSize(width: 32, height: 32)
                    for texture in tileDefinition.textures {
                        texture.filteringMode = .nearest
                    }
                }
            }
        }
    }
            
        
    
    private func setupGridGraph() {
        var obstacles = [GKGridGraphNode]()

        for column in 0..<mapLayer!.numberOfColumns {
                for row in 0..<mapLayer!.numberOfRows {
                    guard let definition = mapLayer!.tileDefinition(atColumn: column, row: row) else { continue }

                    guard let userData = definition.userData else { continue }
                    guard let isObstacle = userData["isObstacle"] else { continue }

                    if isObstacle as! Bool {
                        let obstacleNode = gridGraph.node(atGridPosition: vector_int2(Int32(column),Int32(row)))!
                        obstacles.append(obstacleNode)
                    }
                }
            }
        gridGraph.remove(obstacles)
    }
    
    func rescaleMap() {
        if mapScale == 1 {
            let biggestSize = max(self.size.height, self.size.width)
            mapScale = biggestSize*0.8/1366
        } else {
            mapScale = 1
        }
    }
    
    // MARK: - TILE SELECTOR
    
    func setupTileSelector() {
        tileSelector.size = CGSize(width: 32, height: 32)
        tileSelector.zPosition = 5
        map.addChild(tileSelector)
        let location = mapLayer?.centerOfTile(atColumn: 32, row: 32)
        tileSelector.position = location!
        tileSelector.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "tileSelector1", filter: .nearest),SKTexture(imageNamed: "tileSelector2", filter: .nearest),SKTexture(imageNamed: "tileSelector3", filter: .nearest),SKTexture(imageNamed: "tileSelector4", filter: .nearest),SKTexture(imageNamed: "tileSelector5", filter: .nearest),SKTexture(imageNamed: "tileSelector6", filter: .nearest),SKTexture(imageNamed: "tileSelector7", filter: .nearest),SKTexture(imageNamed: "tileSelector8", filter: .nearest)], timePerFrame: 0.2)))
    }
    
    func moveTheTileSelector(row: Int, column: Int) {
        tileSelector.removeAllActions()
        let location = mapLayer?.centerOfTile(atColumn: column, row: row)
        tileSelector.position = location!
        tileSelector.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "tileSelector1", filter: .nearest),SKTexture(imageNamed: "tileSelector2", filter: .nearest),SKTexture(imageNamed: "tileSelector3", filter: .nearest),SKTexture(imageNamed: "tileSelector4", filter: .nearest),SKTexture(imageNamed: "tileSelector5", filter: .nearest),SKTexture(imageNamed: "tileSelector6", filter: .nearest),SKTexture(imageNamed: "tileSelector7", filter: .nearest),SKTexture(imageNamed: "tileSelector8", filter: .nearest)], timePerFrame: 0.2)))
    }
    
    // MARK: - FOG
    
    
    
    
    
    
    
    // MARK: - UNUSED
    
    
    
    
    
    
    
    //func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
    //    let source = GKPerlinNoiseSource()
    //    source.persistence = 0.95
    //
    //    let noise = GKNoise(source)
    //    let size = vector2(1.0, 1.0)
    //    let randFloat = Double(GKRandomSource.sharedRandom().nextUniform())
    //    let origin = vector2(randFloat, randFloat)
    //    let sampleCount = vector2(Int32(columns), Int32(rows))
    //    return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
    //}
}
