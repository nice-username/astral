//
//  AstralBulletFactory.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

class BulletFactory {
    static func createBullet(from ammoType: AstralWeaponAmmoType, position: CGPoint, direction: CGFloat) -> AstralBullet {
        let behavior: AstralBulletBehavior = determineBehavior(ammoType: ammoType)
        let bullet = AstralBullet(ammoType: ammoType, behavior: behavior, position: position, direction: direction)
        return bullet
    }

    private static func determineBehavior(ammoType: AstralWeaponAmmoType) -> AstralBulletBehavior {
        if ammoType.homing {
            // return HomingBulletBehavior(target: findTarget())
        } else {
            return AstralBulletSingleShot()
        }
    }

    private static func findTarget() -> SKNode? {
        // Logic to find the target
        return nil
    }
}
