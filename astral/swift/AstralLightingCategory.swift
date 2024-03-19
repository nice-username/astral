//
//  AstralLightingCategory.swift
//  astral
//
//  Created by Joseph Haygood on 3/12/24.
//

import Foundation

struct AstralLightingCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let enemy: UInt32 = 0b10
    static let playerBullet: UInt32 = 0b100
    static let enemyBullet: UInt32 = 0b1000
    static let environment: UInt32 = 0b10000
    static let pickup: UInt32 = 0b100000
    static let hazard: UInt32 = 0b1000000
    static let interactive: UInt32 = 0b10000000
    static let background: UInt32 = 0b100000000
    static let foreground: UInt32 = 0b1000000000
    static let specialEffect: UInt32 = 0b10000000000
}
