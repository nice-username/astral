//
//  AstralWeaponBehavior.swift
//  astral
//
//  Created by Joseph Haygood on 4/19/24.
//

import Foundation
import SpriteKit

protocol AstralWeaponBehavior {
    func fire(from unit: SKSpriteNode, at direction: CGFloat, gameScene: SKScene, collider: UInt32)
}
