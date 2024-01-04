//
//  AstralPathNodeProtocol.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation
import SpriteKit

protocol AstralPathNodeProtocol: SKShapeNode {
    var point: CGPoint { get set }
    var attachedToPath: AstralStageEditorPath? { get set }
    var isActive: Bool { get set }
    var timeSinceActivation: TimeInterval { get set }
}
