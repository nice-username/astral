//
//  AstralWeaponMultiShot.swift
//  astral
//
//  Created by Joseph Haygood on 4/21/24.
//

import Foundation
import SpriteKit

class AstralBulletMultiShot: AstralBulletBehavior {
    var numberOfShots: Int
    var spreadAngleDegrees: CGFloat

    init(numberOfShots: Int, spreadAngleDegrees: CGFloat) {
        self.numberOfShots = numberOfShots
        self.spreadAngleDegrees = spreadAngleDegrees
    }

    func apply(to bullet: AstralBullet, deltaTime: TimeInterval) {
        // This behavior is more about initialization rather than continuous application.
    }

    func handleCollision(bullet: AstralBullet, with target: SKNode) {
        bullet.removeFromParent()
    }
    
    /// Calculate the individual shot angles based on the spread and number of shots.
    func calculateShotAngles(baseDirection: CGFloat) -> [CGFloat] {
        var angles: [CGFloat] = []
        let halfSpread = spreadAngleDegrees / 2.0
        let increment = spreadAngleDegrees / CGFloat(numberOfShots - 1)

        for i in 0..<numberOfShots {
            let angleOffset = CGFloat(i) * increment - halfSpread
            angles.append(baseDirection + angleOffset)
        }

        return angles
    }
}
