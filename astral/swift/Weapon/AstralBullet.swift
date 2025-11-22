//
//  AstralBullet.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

class AstralBullet: SKNode {
    var damage: CGFloat
    var moveSpeed: CGFloat
    var behavior: AstralBulletBehavior
    var ammoType: AstralWeaponBulletConfig
    var sprite: AstralSprite
    var impact: AstralSprite
    weak var delegate: AstralWeaponDelegate?

    init(ammoType: AstralWeaponBulletConfig, behavior: AstralBulletBehavior, collider: UInt32, position: CGPoint, direction: CGFloat, scale: Int8 = 1) {
        self.damage     = ammoType.damage
        self.moveSpeed  = ammoType.moveSpeed
        self.ammoType   = ammoType
        self.behavior   = behavior
        self.impact     = AstralSprite(animatedAtlasName: ammoType.impactAtlasName!, timePerFrame: 1 / 15.0, loop: false)
        
        if let spriteFilename = ammoType.spriteFilename {
            if ammoType.isAnimated {
                self.sprite = AstralSprite(animatedAtlasName: spriteFilename, timePerFrame: 1 / 15.0, loop: true)
            } else {
                self.sprite = AstralSprite(imageNamed: spriteFilename)
            }
        } else {
            // Fallback to a default sprite if none specified
            self.sprite = AstralSprite(imageNamed: "default_bullet.png")
        }
        self.sprite.userData = [:]
        
        if scale > 1 {
            self.sprite.xScale = CGFloat(scale)
            self.sprite.yScale = CGFloat(scale)
            self.sprite.texture?.filteringMode = .nearest
            self.impact.xScale = CGFloat(scale)
            self.impact.yScale = CGFloat(scale)
            self.impact.texture?.filteringMode = .nearest
        }
        
        super.init()
        self.position = position
        self.addChild(sprite)
        self.zPosition = 10
        setupPhysics(direction: direction, collider: collider)
        (behavior as? AstralBulletHomingShot)?.startSpinning(bullet: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics(direction: CGFloat, collider: UInt32) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.sprite.size.width / 2)
        self.physicsBody?.categoryBitMask = collider
        self.physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy |
                                               AstralPhysicsCategory.destructible |
                                               AstralPhysicsCategory.obstacle
        self.physicsBody?.collisionBitMask = AstralPhysicsCategory.none
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.angularDamping = 0.0
        let directionRadians = direction * CGFloat.pi / 180.0
        let dx = moveSpeed * cos(directionRadians)
        let dy = moveSpeed * sin(directionRadians)
        self.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
    }
    
    func update(deltaTime: TimeInterval) {
        behavior.apply(to: self, deltaTime: deltaTime)
    }    
    
    func handleCollision(bullet: AstralBullet, with target: SKNode) {
        bullet.behavior.handleCollision(bullet: bullet, with: target)
        delegate?.removeBullet(bullet)
    }
}

