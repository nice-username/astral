//
//  AstralBulletHomingShot.swift
//  astral
//
//  Created by Joseph Haygood on 4/22/24.
//

import Foundation
import SpriteKit

class AstralBulletHomingShot: AstralBulletBehavior {
    var target: SKNode?
    var nudgeStrength: CGFloat

    init(target: SKNode?, nudgeStrength: CGFloat = 0.05) {
        self.target = target
        self.nudgeStrength = nudgeStrength
    }

    func apply(to bullet: AstralBullet, deltaTime: TimeInterval) {
        honeInTowardTarget(bullet: bullet)
    }

    func handleCollision(bullet: AstralBullet, with target: SKNode) {
        bullet.removeFromParent()
    }

    private func honeInTowardTarget(bullet: AstralBullet) {
        guard let target = self.target, let physicsBody = bullet.physicsBody else {
            return  // If there's no target or physics body, we can't adjust the trajectory
        }
        
        let targetPosition = target.position
        let currentPosition = bullet.position
        let vectorToTarget = CGVector(dx: targetPosition.x - currentPosition.x, dy: targetPosition.y - currentPosition.y)
        let normalizedVector = vectorToTarget.normalized()
        let adjustedVelocity = CGVector(dx: physicsBody.velocity.dx + normalizedVector.dx * nudgeStrength,
                                        dy: physicsBody.velocity.dy + normalizedVector.dy * nudgeStrength)
        physicsBody.velocity = adjustedVelocity
    }


    /// Call this method once when the bullet is created to initiate continuous spinning.
    func startSpinning(bullet: AstralBullet) {
        let spinAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
        let repeatSpinAction = SKAction.repeatForever(spinAction)
        bullet.sprite.run(repeatSpinAction, withKey: "spinning")
    }
}
