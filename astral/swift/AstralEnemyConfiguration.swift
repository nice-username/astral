//
//  AstralEnemyConfiguration.swift
//  astral
//
//  Created by Joseph Haygood on 12/26/23.
//

import Foundation
import SpriteKit

struct AstralEnemyConfiguration {
    var health: Int
    var maxHealth: Int
    var movementSpeed: CGFloat
    var atlasName: String
    var textures: [SKTexture] = []
    var texturesWhite: [SKTexture] = []
    var polarity: AstralPolarity?
    var particleSystem: AstralParticleSystem?
    var hitbox: SKShapeNode?
    var currentSpriteID: Int = 6
    var targetRestingFrame: Int = 6
    var weapons: [AstralWeapon] = []
    var orders: [AstralEnemyOrder] = []
    var isShooting: Bool = false
    let joystick: AstralJoystick = AstralJoystick()
    var speedUpChangeTimeLeft: Double = 0.0
    var speedDownChangeTimeLeft: Double = 0.0
    var currentPath: AstralStageEditorPath?
}
