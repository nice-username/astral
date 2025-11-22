//
//  AstralPlayerEntity.swift
//  astral
//
//  Created by Joseph Haygood on 2/16/25.
//

import Foundation
import SpriteKit
import GameplayKit

class PlayerEntity: GKEntity {
    init(position: CGPoint, joystick: AstralJoystick) {
        super.init()
        
        // Basic node component
        let node = SKNode()
        node.position = position
        addComponent(GKSKNodeComponent(node: node))
        
        // Texture component
        addComponent(AstralTextureComponent(atlasNamed: "AstralPlayer"))
        
        /*
        // Render component
        addComponent(AstralRenderComponent(
            entityType: .player,
            size: CGSize(width: 64, height: 64)
        ))
        */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
