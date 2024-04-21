//
//  AstralWeaponFactory.swift
//  astral
//
//  Created by Joseph Haygood on 4/19/24.
//

import Foundation

class WeaponFactory {
    func createWeapon(type: AstralWeaponAmmoType) -> AstralWeaponBehavior? {
        switch type {
        // case .beam:
        //     return AstralWeaponBeam()
        case .singleShot:
            return AstralWeaponSingleShot()
        // case .shotgun:
        //    return AstralWeaponShotgun()
        default:
            return nil
        }
    }
}
