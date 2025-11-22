//
//  AstralEntity.swift
//  astral
//
//  Created by Joseph Haygood on 2/14/25.
//
import GameplayKit
import SpriteKit

class AstralEntity: GKEntity {
    let entityId: UUID 
    let type: AstralEntityType

    /// Convenience accessor for position
    var position: CGPoint {
        get { return node?.position ?? .zero }
        set { node?.position = newValue }
    }
    
    init(type: AstralEntityType, node: SKNode) {
        self.entityId = UUID()
        self.type = type
        super.init()
        
        addComponent(GKSKNodeComponent(node: node))
        addComponent(StateComponent())  // Track entity state
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        component(ofType: StateComponent.self)?.isActive = false
        node?.removeAllActions()
        node?.removeFromParent()
        node?.position = .zero
        node?.zRotation = 0

        for component in components {
            (component as? Resettable)?.reset()
        }
    }
}
