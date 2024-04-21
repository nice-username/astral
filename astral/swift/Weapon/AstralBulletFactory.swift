//
//  AstralBulletFactory.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

class AstralBulletFactory {
    static func createBullet(from ammoType: AstralWeaponAmmoType, collider: UInt32, position: CGPoint, direction: CGFloat, scale: Int8 = 1) -> AstralBullet {
        let behavior: AstralBulletBehavior = determineBehavior(ammoType: ammoType)
        let bullet = AstralBullet(ammoType: ammoType, behavior: behavior, collider: collider, position: position, direction: direction, scale: scale)
        return bullet
    }

    private static func determineBehavior(ammoType: AstralWeaponAmmoType) -> AstralBulletBehavior {
        if ammoType.homing {
            // return HomingBulletBehavior(target: findTarget())
        } else {
            return AstralBulletSingleShot()
        }
        return AstralBulletSingleShot()
    }

    private static func findTarget() -> SKNode? {
        // Logic to find the target
        return nil
    }
}
