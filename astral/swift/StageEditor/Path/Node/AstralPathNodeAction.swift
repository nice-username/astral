//
//  AstralPathNodeAction.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/24.
//

import Foundation
import UIKit


class AstralPathNodeAction: AstralPathNode {
    var action: AstralEnemyOrder?
    var triggeredByEnemies = Set<UUID>()
    
    override init(point: CGPoint) {
        super.init(point: point)
        self.fillColor = UIColor(red:   224 / 255.0,
                                 green: 16  / 255.0,
                                 blue:  24  / 255.0,
                                 alpha: 255 / 255.0)
    }
    
    convenience init(from: AstralPathNodeActionData) {
        self.init(point: from.baseNodeData.point)
    }
    
    func performAction(for enemy: AstralEnemy) {
        guard let action = action else {
            print("No action defined for this node.")
            return
        }

        // Check if this enemy has already triggered the action
        if triggeredByEnemies.contains(enemy.id) {
            return // The action has already been performed for this enemy
        }
        
        // Perform the action here
        switch action.type {
        case .turnRight(let duration, let angle), .turnLeft(let duration, let angle):
            enemy.turn(direction: action.type, duration: duration, angle: angle)
            
        case .fire:
            enemy.isShooting = true
            
        case .fireStop:
            enemy.isShooting = false
            break
            
        default:
            break
        }

        // Mark this node as triggered by the current enemy
        triggeredByEnemies.insert(enemy.id)
    }

    // Call this method when you want to reset the node, for example, when a new level starts
    func reset() {
        triggeredByEnemies.removeAll()
    }
    
    func isTriggered(by enemy: AstralEnemy) -> Bool {
        return triggeredByEnemies.contains(enemy.id)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
