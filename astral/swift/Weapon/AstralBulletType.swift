//
//  AstralBulletType.swift
//  astral
//
//  Created by Joseph Haygood on 4/23/24.
//

import Foundation


enum AstralBulletType: Int {
    case singleShot         // Straight ahead
    case shotgun            // 0 / 30 / -30 degree
    case laserBeam          // Straight line splash damage
    case homing             // Sweep the screen -> launch slow but strong missiles that hone in with splash damage
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
