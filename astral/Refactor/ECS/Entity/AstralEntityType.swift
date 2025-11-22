//
//  AstralEntityType.swift
//  astral
//
//  Created by Joseph Haygood on 2/14/25.
//

import Foundation

enum AstralEntityType: CaseIterable {
    case player
    case enemy
    case boss
    case bullet
    case powerUp
    case neutralObject
    case obstacle      // Walls, barriers, or destructible objects
    case projectile    // Separate from bullets if needed (e.g., lasers, missiles)
    case collectible   // Score items, upgrades, or special pickups
    case effect        // Temporary visual/gameplay effects (e.g., explosions)
    case ally          // NPCs that help the player
}
