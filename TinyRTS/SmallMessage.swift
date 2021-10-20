//
//  SmallMessage.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 06/09/2021.
//

import Foundation
import UIKit
import SpriteKit
import GameKit

struct SmallMessage: Codable {
    
    var life: Int = 0
    var position: [Int] = [0,0]
    
}


extension SmallMessage {
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func decode(data: Data) -> SmallMessage? {
        return try? JSONDecoder().decode(SmallMessage.self, from: data)
    }
}
