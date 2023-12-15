//
//  AstralPathNode.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation
import SpriteKit

enum AstralPathNodeType {
    case action
    case creation
    case effect
    case path
}

class AstralPathNode {
    var type: AstralPathNodeType?
    var point: CGPoint
    var order: AstralEnemyOrder
    var attachedToPath: AstralStageEditorPath?
    var shape: SKShapeNode
    
    init(point: CGPoint, order: AstralEnemyOrder) {
        self.point = point
        self.order = order
        self.shape = SKShapeNode()
    }
    
    private func createShape(size: CGFloat) {
        
    }
}
