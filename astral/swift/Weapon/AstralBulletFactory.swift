//
//  AstralBulletFactory.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

class AstralBulletFactory {
    static var getTargets: (() -> [AstralEnemy])?

    static func createBullet(from ammoType: AstralWeaponBulletConfig, collider: UInt32, position: CGPoint, direction: CGFloat, scale: Int8 = 1) -> AstralBullet {
        let behavior: AstralBulletBehavior = determineBehavior(ammoType: ammoType)
        let bullet = AstralBullet(ammoType: ammoType, behavior: behavior, collider: collider, position: position, direction: direction, scale: scale)
        return bullet
    }

    private static func determineBehavior(ammoType: AstralWeaponBulletConfig) -> AstralBulletBehavior {
        if ammoType.type == .homing {
            let target = findTarget()  // Ensure this actually retrieves a valid target
            return AstralBulletHomingShot(target: target, nudgeStrength: 4.0)  // Customize the nudge strength as needed
        }
        if ammoType.type == .shotgun {
            return AstralBulletMultiShot(numberOfShots: Int(ammoType.range), spreadAngleDegrees: ammoType.spread)
        }
        return AstralBulletSingleShot()
    }


    private static func findTarget() -> SKNode? {
        guard let enemies = getTargets?(), !enemies.isEmpty else { return nil }
        // Example: Selecting the first enemy as the target
        // We want to implement more sophisticated target selection logic here
        return enemies.first
    }
}
