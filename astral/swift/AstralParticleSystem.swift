//
//  AstralParticleSystem.swift
//  astral
//
//  Created by Joseph Haygood on 5/1/23.
//

import Foundation
import SpriteKit

class AstralParticleSystem: SKNode {
    private let emitterNode: SKEmitterNode
    
    init(player: SKSpriteNode) {
        self.emitterNode = SKEmitterNode(fileNamed: "Thruster")!
        self.emitterNode.particleTexture?.filteringMode = .nearest
        //self.emitterNode.particlePositionRange = CGVector(dx: player.size.width / 2, dy: 0)
        super.init()
        self.position.y -= 20.0
        self.addChild(self.emitterNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(player: AstralPlayer, joystickDirection: AstralDirection) {
        var angle: CGFloat = -90.0
        var multiplierSpeed: CGFloat = 1.0
        var multiplierBirthRate: CGFloat = 1.0
        var scale: CGFloat = 1.0

        switch joystickDirection {
        case .up:
            scale               = 2.0
            multiplierSpeed     = 25
            multiplierBirthRate = 30
        case .upLeft:
            scale               = 1.8
            angle               = 0.0
            multiplierSpeed     = 20
            multiplierBirthRate = 20
        case .left:
            scale               = 1.5
            angle               = CGFloat.pi / 2
            multiplierSpeed     = 15
            multiplierBirthRate = 15
        case .downLeft:
            scale               = 0.6667
            angle               = 3 * CGFloat.pi / 4
            multiplierSpeed     = 15
            multiplierBirthRate = 20
        case .down:
            scale               = 1.0
            angle               = CGFloat.pi
            multiplierSpeed     = 10
            multiplierBirthRate = 15
        case .downRight:
            scale               = 0.6667
            angle               = 5 * CGFloat.pi / 4
            multiplierSpeed     = 15
            multiplierBirthRate = 20
        case .right:
            scale               = 1.5
            angle               = 3 * CGFloat.pi / 2
            multiplierSpeed     = 15
            multiplierBirthRate = 15
        case .upRight:
            scale               = 1.8
            angle               = 7 * CGFloat.pi / 4
            multiplierSpeed     = 20
            multiplierBirthRate = 20
        case .none:
            scale               = 1.5
            multiplierSpeed     = 15
            multiplierBirthRate = 15
        }
        // self.emitterNode.emissionAngle = angle
        self.emitterNode.particleSpeed = multiplierSpeed
        self.emitterNode.particleScale = scale
        self.emitterNode.particleBirthRate = multiplierBirthRate
    }

    
    
    func addToNode(_ node: SKNode) {
        node.addChild(emitterNode)
    }
    
    func removeFromNode(_ node: SKNode) {
        emitterNode.removeFromParent()
    }
    
    func setPosition(_ position: CGPoint) {
        emitterNode.position = position
    }
    
}
