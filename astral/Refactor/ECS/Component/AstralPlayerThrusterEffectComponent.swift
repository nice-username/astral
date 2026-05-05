//
//  AstralPlayerThrusterEffectComponent.swift
//  astral
//
//  Created by Joseph Haygood on 4/26/26.
//

import Foundation
import GameplayKit
import SpriteKit

class AstralPlayerThrusterEffectComponent: GKComponent, Resettable {
    private weak var joystick: AstralJoystick?
    private var emitter: SKEmitterNode?

    init(joystick: AstralJoystick) {
        self.joystick = joystick
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        setupEmitter()
        updateParticles(for: .none)
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let joystick = joystick else { return }
        updateParticles(for: joystick.direction)
    }

    private func setupEmitter() {
        guard emitter == nil,
              let sprite = entity?.node as? SKSpriteNode,
              let emitter = SKEmitterNode(fileNamed: "Thruster") else { return }

        emitter.particleTexture?.filteringMode = .nearest
        emitter.position.y = -20.0
        emitter.zPosition = -1
        sprite.addChild(emitter)
        self.emitter = emitter
    }

    private func updateParticles(for direction: AstralDirection) {
        guard let emitter = emitter else { return }

        var particleSpeed: CGFloat = 15
        var particleBirthRate: CGFloat = 15
        var particleScale: CGFloat = 1.5

        switch direction {
        case .up:
            particleScale = 2.0
            particleSpeed = 25
            particleBirthRate = 30
        case .upLeft, .upRight:
            particleScale = 1.8
            particleSpeed = 20
            particleBirthRate = 20
        case .left, .right:
            particleScale = 1.5
            particleSpeed = 15
            particleBirthRate = 15
        case .downLeft, .downRight:
            particleScale = 0.6667
            particleSpeed = 15
            particleBirthRate = 20
        case .down:
            particleScale = 1.0
            particleSpeed = 10
            particleBirthRate = 15
        case .none:
            break
        }

        emitter.particleSpeed = particleSpeed
        emitter.particleScale = particleScale
        emitter.particleBirthRate = particleBirthRate
    }

    func reset() {
        updateParticles(for: .none)
    }
}
