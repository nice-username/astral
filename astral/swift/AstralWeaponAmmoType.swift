//
//  AmmoType.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//

import Foundation

/*
enum AmmoType: Int {
    case singleShot         // Straight ahead
    case tripleShot         // 0 / 30 / -30 degree
    case laserBeam          // Straight line splash damage
    case homingMissiles     // Sweep the screen -> launch slow but strong missiles that hone in with splash damage
    case EMP                // Disable enemies / special / elemental
    case flamethrower       // Splash damage in an area
    case grenade            // Splash damage in an area
    case ionCannon          // Elemential / special type (vs. electronics
    case gravity            // Suck enemies into bullets
    case lightning          // Connects to the nearest enemy
    case arcLightning       // Connects to several enemies
    case sonicWave          // Radiates outwards
    case chain              // Connects with nearby enemies
    case waterJet           // Push player backwards -> elemental / special type
    case lockOnLaser        // Sweep the screen like StarFox -> deal large damage
}
*/

class AstralWeaponAmmoType {
    let name: String
    let description: String
    let spriteFilename: String
    let damage: CGFloat
    let speed: CGFloat
    let range: CGFloat
    let spread: CGFloat
    let homing: Bool
    let splash: Bool
    
    
    init(name: String, description: String, spriteFilename: String, damage: CGFloat, speed: CGFloat, range: CGFloat, spread: CGFloat, homing: Bool, splash: Bool) {
        self.name = name
        self.description = description
        self.spriteFilename = spriteFilename
        self.damage = damage
        self.speed = speed
        self.range = range
        self.spread = spread
        self.homing = homing
        self.splash = splash
    }
    
    static var singleShot: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Single Shot",
                        description: "Fires a single shot straight ahead",
                        spriteFilename: "bullet00",
                        damage: 4,
                        speed: 40,
                        range: 500,
                        spread: 0,
                        homing: false,
                        splash: false)
    }
    
    static var tripleShot: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Triple Shot", description: "Fires three shots at 0, 30, and -30 degree angles", spriteFilename: "bullet00", damage: 5, speed: 400, range: 400, spread: 30, homing: false, splash: false)
    }
    // Add more ammo types as needed...
}
