//
//  AstralWeaponDelegate.swift
//  astral
//
//  Created by Joseph Haygood on 4/24/24.
//

import Foundation

protocol AstralWeaponDelegate: AnyObject {
    func addBullet(_ bullet: AstralBullet)
    func removeBullet(_ bullet: AstralBullet)
}
