//
//  ImmediatePGR.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 15/08/2021.
//

import UIKit

class ImmediatePGR: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if touches.count > 1 {
            self.state = .began
        }
    }
}
