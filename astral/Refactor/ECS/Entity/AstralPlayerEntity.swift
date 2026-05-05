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
    var health: Int = 1
    var maxHealth: Int = 1

    var movementSpeed: CGFloat {
        get {
            component(ofType: AstralPlayerMovementComponent.self)?.movementSpeed ?? 0
        }
        set {
            component(ofType: AstralPlayerMovementComponent.self)?.movementSpeed = newValue
        }
    }

    private static let defaultMovementSpeed: CGFloat = 8.0

    init(scene: SKScene, position: CGPoint, joystick: AstralJoystick) {
        let textureComponent = AstralTextureComponent(atlasNamed: AstralPlayerTurnAnimationComponent.atlasName)
        let initialTexture = textureComponent.textures.indices.contains(AstralPlayerTurnAnimationComponent.restingFrameIndex)
            ? textureComponent.textures[AstralPlayerTurnAnimationComponent.restingFrameIndex]
            : SKTexture(imageNamed: "frame06.png")

        let sprite = SKSpriteNode(texture: initialTexture)
        sprite.position = position
        sprite.zPosition = 2
        sprite.name = "player"

        super.init(type: .player, node: sprite)

        addComponent(textureComponent)
        addComponent(AstralPlayerPolarityComponent())
        addComponent(AstralPlayerMovementComponent(joystick: joystick, movementSpeed: Self.defaultMovementSpeed))
        addComponent(AstralPlayerTurnAnimationComponent(joystick: joystick))
        addComponent(AstralPlayerThrusterEffectComponent(joystick: joystick))

        setupPhysics(sprite: sprite)
        scene.addChild(sprite)
        component(ofType: AstralStateComponent.self)?.isActive = true
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

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
    }

    func setSprite(inputValue: CGFloat) {
        component(ofType: AstralPlayerTurnAnimationComponent.self)?.setSprite(inputValue: inputValue)
    }

    func animateToRestingPosition(duration: TimeInterval) {
        component(ofType: AstralPlayerTurnAnimationComponent.self)?.animateToRestingPosition(duration: duration)
    }

    func damage(amount: Int = 1) {
        health -= amount
        if health <= 0 {
            die()
        }
    }

    func die() {
        component(ofType: AstralStateComponent.self)?.isActive = false
        node?.removeFromParent()
    }

    override func reset() {
        super.reset()
        health = maxHealth
    }
}
