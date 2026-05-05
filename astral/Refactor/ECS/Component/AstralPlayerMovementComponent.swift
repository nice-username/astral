//
//  AstralPlayerMovementComponent.swift
//  astral
//
//  Created by Joseph Haygood on 4/26/26.
//

import Foundation
import GameplayKit
import SpriteKit

class AstralPlayerMovementComponent: GKComponent, Resettable {
    private weak var joystick: AstralJoystick?
    private let defaultMovementSpeed: CGFloat

    var movementSpeed: CGFloat

    init(joystick: AstralJoystick, movementSpeed: CGFloat = 8.0) {
        self.joystick = joystick
        self.defaultMovementSpeed = movementSpeed
        self.movementSpeed = movementSpeed
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let joystick = joystick,
              let velocity = joystick.normalizedVelocity,
              let node = entity?.node else { return }

        node.position = CGPoint(
            x: node.position.x + velocity.dx * movementSpeed,
            y: node.position.y + velocity.dy * movementSpeed
        )
    }

    func reset() {
        movementSpeed = defaultMovementSpeed
    }
}
