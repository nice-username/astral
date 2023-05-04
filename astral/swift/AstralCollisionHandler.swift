//
//  AstralCollisionHandler.swift
//  astral
//
//  Created by Joseph Haygood on 5/3/23.
//

import Foundation
import SpriteKit

class AstralCollisionHandler {
    let removeAction = SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.removeFromParent()])
    var player : AstralPlayer? = nil
    
    func handleContact(contact: SKPhysicsContact) {
        let cat1 = contact.bodyA.categoryBitMask
        let cat2 = contact.bodyB.categoryBitMask
        
        // Bullet vs. screen boundaries
        if cat1 == AstralPhysicsCategory.bullet && cat2 == AstralPhysicsCategory.boundary {
            contact.bodyA.node?.run(self.removeAction)
        } else if cat1 == AstralPhysicsCategory.boundary && cat2 == AstralPhysicsCategory.bullet {
            contact.bodyB.node?.run(self.removeAction)
        }
        
        // Bullet vs. enemy
        if cat1 == AstralPhysicsCategory.bullet && cat2 == AstralPhysicsCategory.enemy {
            contact.bodyA.node?.removeFromParent()
            if let enemyNode = contact.bodyB.node as? AstralEnemy {
                enemyNode.takeDamage()
            }
        } else if cat1 == AstralPhysicsCategory.enemy && cat2 == AstralPhysicsCategory.bullet {
            var dmg = player!.weapons[0].damage
            if let enemyNode = contact.bodyA.node as? AstralEnemy {
                enemyNode.takeDamage(amount: dmg)
                let impactSound = SKAction.playSoundFileNamed("impact00", waitForCompletion: false)
                enemyNode.run(impactSound)
            }
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    
    
    private func handleEnemyCollision(contact: SKPhysicsContact) {
        // Handle enemy collision with other objects
        // ...
    }
    
    private func handlePlayerCollision(contact: SKPhysicsContact) {
        // Handle player collision with other objects
        // ...
    }
    
}

