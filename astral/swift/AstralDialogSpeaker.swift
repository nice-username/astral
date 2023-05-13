//
//  AstralDialogSpeaker.swift
//  astral
//
//  Created by Joseph Haygood on 5/12/23.
//

import Foundation
import SpriteKit

class AstralDialogSpeaker: SKNode {
    var sprite: SKSpriteNode!
    
    init(at point: CGPoint) {
        super.init()
        self.position = point
        
        let sprite    = SKSpriteNode(imageNamed: "DialogSpeaker")
        sprite.texture?.filteringMode = .nearest
        sprite.xScale = 3.0
        sprite.yScale = 3.0
        sprite.zPosition = 4.0
        
        self.addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
