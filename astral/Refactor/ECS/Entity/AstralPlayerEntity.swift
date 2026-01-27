//
//  AstralPlayerEntity.swift
//  astral
//
//  Created by Joseph Haygood on 2/16/25.
//

import Foundation
import SpriteKit
import GameplayKit

class AstralPlayerEntity: AstralEntity {
    // Movement
    var movementSpeed: CGFloat = 8.0

    // Health
    var health: Int = 1
    var maxHealth: Int = 1

    // Reference to joystick for input
    private weak var joystick: AstralJoystick?

    init(scene: SKScene, position: CGPoint, joystick: AstralJoystick) {
        self.joystick = joystick

        // Create the sprite node
        let sprite = SKSpriteNode(imageNamed: "frame06.png")
        sprite.position = position
        sprite.zPosition = 2
        sprite.texture?.filteringMode = .nearest

        super.init(type: .player, node: sprite)

        // Add polarity component
        addComponent(AstralPolarityComponent())

        // Setup physics
        setupPhysics(sprite: sprite)

        // Add to scene
        scene.addChild(sprite)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics(sprite: SKSpriteNode) {
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody?.categoryBitMask = AstralPhysicsCategory.player
        sprite.physicsBody?.collisionBitMask = AstralPhysicsCategory.boundary | AstralPhysicsCategory.obstacle
        sprite.physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.boundary | AstralPhysicsCategory.bulletEnemy
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.affectedByGravity = false
    }

    func update(deltaTime: TimeInterval) {
        guard let joystick = joystick,
              let velocity = joystick.velocity else { return }

        let newX = position.x + velocity.dx * movementSpeed
        let newY = position.y + velocity.dy * movementSpeed
        position = CGPoint(x: newX, y: newY)
    }

    func damage(amount: Int = 1) {
        health -= amount
        if health <= 0 {
            die()
        }
    }

    func die() {
        component(ofType: StateComponent.self)?.isActive = false
        node?.removeFromParent()
    }

    override func reset() {
        super.reset()
        health = maxHealth
        movementSpeed = 8.0
    }
}
