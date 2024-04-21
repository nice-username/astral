//
//  AstralBulletSingleShot.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

/// A behavior class for bullets that travel in a straight line at a constant speed.
class AstralBulletSingleShot: AstralBulletBehavior {
    func apply(to bullet: AstralBullet, deltaTime: TimeInterval) {
        // For a simple single shot, there might not be any need to continuously update properties.
        // However, if you need to adjust velocity due to game mechanics, you can do it here.
        // This method is kept for potential future adjustments or enhancements.
    }

    func handleCollision(bullet: AstralBullet, with target: SKNode) {
        // Perform any actions that should occur when the bullet collides with another object.
        // Typically, this would include applying damage to the target and destroying the bullet.
        bullet.removeFromParent()
    }
}
