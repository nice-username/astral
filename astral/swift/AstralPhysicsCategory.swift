//
//  AstralPhysicsCategory.swift
//  astral
//
//  Created by Joseph Haygood on 5/1/23.
//

import Foundation

struct AstralPhysicsCategory {
    static let none: UInt32              = 0
    static let boundary: UInt32          = 1 << 0
    static let player: UInt32            = 1 << 1
    static let bulletPlayer: UInt32      = 1 << 2
    static let laser: UInt32             = 1 << 3
    static let enemy: UInt32             = 1 << 4
    static let powerUp: UInt32           = 1 << 5
    static let obstacle: UInt32          = 1 << 6
    static let collectible: UInt32       = 1 << 7
    static let destructible: UInt32      = 1 << 8
    static let hazard: UInt32            = 1 << 9
    static let bulletEnemy: UInt32       = 1 << 10
    static let region: UInt32            = 1 << 11
    static let trigger: UInt32           = 1 << 12
    static let spawnPoint: UInt32        = 1 << 13
    static let checkpoint: UInt32        = 1 << 14
    static let exit: UInt32              = 1 << 15
}
