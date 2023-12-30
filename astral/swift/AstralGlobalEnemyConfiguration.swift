//
//  AstralGlobalEnemyConfig.swift
//  astral
//
//  Created by Joseph Haygood on 12/26/23.
//

import Foundation
import SpriteKit

let AstralGlobalEnemyConfiguration : [String: AstralEnemyConfiguration] = [
    "enemy1": AstralEnemyConfiguration(health: 8,
                                       maxHealth: 8,
                                       movementSpeed: 10,
                                       atlasName: "fighter2",
                                       textures: AstralEnemy.loadTextures(fromAtlasNamed: "fighter2", namingStyle: .angleSequence),
                                       polarity: .white,
                                       targetRestingFrame: 0,
                                       weapons: [],
                                       speedUpChangeTimeLeft: 0.0,
                                       speedDownChangeTimeLeft: 0.0,
                                       currentPath: nil)
]
