//
//  AstralWeapon.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//

import Foundation
import SpriteKit

class AstralWeapon: SKNode {
    var damage: CGFloat
    var cooldownTime: TimeInterval
    var reloadTime: TimeInterval
    var clipSize: Int
    var range: CGFloat
    var ammoType: AstralWeaponAmmoType
    // var soundEffect: SKAction
    /*
    let ammoType: AstralWeaponAmmoType
    var ammoCount: Int
    let maxAmmoCount: Int
    
    var isReloading: Bool = false
    var isCoolingDown: Bool = false
    private var timeSinceLastShot: TimeInterval = 0.0
    */
    

    init(name: String, damage: CGFloat, cooldown: TimeInterval, range: CGFloat, ammoType: AstralWeaponAmmoType, reloadTime: TimeInterval, clipSize: Int) {
       
        self.damage = damage
        self.cooldownTime = cooldown
        self.range = range
        self.ammoType = ammoType
        self.reloadTime = reloadTime
        // self.soundEffect = soundEffect
        self.clipSize = clipSize
        super.init()
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fire(at direction: CGVector) {
        // Code to handle firing the weapon at the specified direction
        
    }

    func reload() {
        // Code to handle reloading the weapon
    }
}
