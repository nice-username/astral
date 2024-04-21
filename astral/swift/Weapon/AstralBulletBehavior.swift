//
//  AstralBulletBehavior.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

protocol AstralBulletBehavior {
    func apply(to bullet: AstralBullet, deltaTime: TimeInterval)
    func handleCollision(bullet: AstralBullet, with target: SKNode)
}
