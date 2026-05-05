//
//  AstralPlayerTurnAnimationComponent.swift
//  astral
//
//  Created by Joseph Haygood on 4/26/26.
//

import Foundation
import GameplayKit
import SpriteKit

class AstralPlayerTurnAnimationComponent: GKComponent, Resettable {
    static let atlasName = "AstralPlayer"
    static let restingFrameIndex = 6

    private weak var joystick: AstralJoystick?
    private let defaultRestingDuration: TimeInterval = 0.15
    private var lastDirection: AstralDirection = .none

    private var sprite: SKSpriteNode? {
        entity?.node as? SKSpriteNode
    }

    private var textures: [SKTexture] {
        entity?.component(ofType: AstralTextureComponent.self)?.textures ?? []
    }

    init(joystick: AstralJoystick) {
        self.joystick = joystick
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let joystick = joystick else { return }

        let direction = joystick.direction
        if direction != .none {
            lastDirection = direction
        } else if lastDirection != .none {
            animateToRestingPosition(duration: defaultRestingDuration)
            lastDirection = .none
        }
    }

    func setSprite(inputValue: CGFloat) {
        guard let sprite = sprite else { return }

        sprite.removeAction(forKey: "returnToRest")

        let clampedInput = max(-1.0, min(1.0, inputValue))
        let index = Int(round(clampedInput * 5)) + Self.restingFrameIndex

        if textures.indices.contains(index) {
            sprite.texture = textures[index]
        }
    }

    func animateToRestingPosition(duration: TimeInterval) {
        guard let sprite = sprite,
              let currentTexture = sprite.texture,
              let currentFrame = textures.firstIndex(of: currentTexture) else { return }

        let frameDifference = abs(Self.restingFrameIndex - currentFrame)
        guard frameDifference > 0 else { return }

        let frameDuration = duration / Double(frameDifference)
        let direction = currentFrame < Self.restingFrameIndex ? 1 : -1

        var actions: [SKAction] = []
        var frame = currentFrame
        while frame != Self.restingFrameIndex {
            frame += direction
            let texture = textures[frame]
            actions.append(
                SKAction.sequence([
                    SKAction.setTexture(texture),
                    SKAction.wait(forDuration: frameDuration),
                ])
            )
        }

        sprite.run(SKAction.sequence(actions), withKey: "returnToRest")
    }

    func reset() {
        lastDirection = .none
        sprite?.removeAction(forKey: "returnToRest")

        if let sprite = sprite, textures.indices.contains(Self.restingFrameIndex) {
            sprite.texture = textures[Self.restingFrameIndex]
        }
    }
}
