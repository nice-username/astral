//
//  AstralUnit.swift
//  astral
//
//  Created by Joseph Haygood on 5/3/23.
//

import Foundation
import SpriteKit


protocol AstralUnit {
    var health: Int { get set }
    var maxHealth: Int { get }
    var movementSpeed: CGFloat { get set }
    var atlasName: String { get set }
    var textures: [SKTexture] { get }
    var polarity: AstralPolarity { get set }
    var particleSystem: AstralParticleSystem? { get set }
    var hitbox: SKShapeNode? { get set }
    var weapons: [AstralWeapon] { get set }

    func update(currentTime: TimeInterval, deltaTime: TimeInterval)
    func moveBy(_ vector: CGVector)
}
