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
    var ammoType: AstralWeaponAmmoType
    var sprite: AstralSprite

    init(ammoType: AstralWeaponAmmoType, behavior: AstralBulletBehavior, position: CGPoint, direction: CGFloat) {
        self.damage = ammoType.damage
        self.moveSpeed = ammoType.moveSpeed
        self.ammoType = ammoType
        if let spriteFilename = ammoType.spriteFilename {
            if ammoType.isAnimated {
                // Create an animated sprite if the ammo type specifies animations
                self.sprite = AstralSprite(animatedAtlasName: spriteFilename, timePerFrame: 1/15.0, loop: true)
            } else {
                // Create a static sprite if no animation is needed
                self.sprite = AstralSprite(imageNamed: spriteFilename)
            }
        } else {
            // Fallback to a default sprite if none specified
            self.sprite = AstralSprite(imageNamed: "default_bullet.png")
        }
        super.init()
        self.position = position
        self.addChild(sprite)
        setupPhysics(direction: direction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics(direction: CGFloat) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.sprite.size.width / 2)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = AstralPhysicsCategory.bulletEnemy
        self.physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy
        self.physicsBody?.collisionBitMask = 0
        let dx = moveSpeed * cos(direction)
        let dy = moveSpeed * sin(direction)
        self.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
    }
    
    func update(deltaTime: TimeInterval) {
        behavior.apply(to: self, deltaTime: deltaTime)
    }

    private func runAnimation() {
        // Run animation if needed
    }
}

