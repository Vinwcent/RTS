//
//  PixelArt.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 14/08/2021.
//

import SpriteKit
import GameplayKit

extension SKTexture {
    convenience init(imageNamed: String, filter: SKTextureFilteringMode) {
        self.init(imageNamed: imageNamed)
        self.filteringMode = filter
    }
}
    
extension Array where Element: Equatable {
    func haveTheSameElement(as other: [Element]) -> [Any] {
        for i in 0..<other.count {
            if self.contains(other[i]) {
                return [other[i],i]
            }
        }
        return [false]
    }
}

extension SKSpriteNode {
    
    func drawBorder(color: UIColor, width: CGFloat) {
        removeAllChildren()
        let shapeNode = SKShapeNode(rectOf: size)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        shapeNode.zPosition = zPosition
        addChild(shapeNode)
    }
}
