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
        if cat1 == AstralPhysicsCategory.bulletPlayer && cat2 == AstralPhysicsCategory.boundary {
            contact.bodyA.node?.run(self.removeAction)
        } else if cat1 == AstralPhysicsCategory.boundary && cat2 == AstralPhysicsCategory.bulletPlayer {
            contact.bodyB.node?.run(self.removeAction)
        }
        if cat1 == AstralPhysicsCategory.bulletEnemy && cat2 == AstralPhysicsCategory.boundary {
            contact.bodyA.node?.run(self.removeAction)
        } else if cat1 == AstralPhysicsCategory.boundary && cat2 == AstralPhysicsCategory.bulletEnemy {
            contact.bodyB.node?.run(self.removeAction)
        }
        
        // Bullet vs. enemy
        if cat1 == AstralPhysicsCategory.bulletPlayer && cat2 == AstralPhysicsCategory.enemy {
            contact.bodyA.node?.removeFromParent()
            if let enemyNode = contact.bodyB.node as? AstralEnemy {
                enemyNode.takeDamage()
            }
        } else if cat1 == AstralPhysicsCategory.enemy && cat2 == AstralPhysicsCategory.bulletPlayer {
            var dmg = player!.weapons[0].damage
            if let enemyNode = contact.bodyA.node as? AstralEnemy {
                enemyNode.takeDamage(amount: dmg)
                let impactSound = SKAction.playSoundFileNamed("impact00", waitForCompletion: false)
                enemyNode.run(impactSound)
            }
            contact.bodyB.node?.removeFromParent()
        }
        
        
        // Bullet vs. Player
        if cat1 == AstralPhysicsCategory.bulletEnemy && cat2 == AstralPhysicsCategory.player {
            contact.bodyA.node?.removeFromParent()
            if let player = contact.bodyB.node as? AstralPlayer {
                player.damage()
            }
        } else if cat1 == AstralPhysicsCategory.player && cat2 == AstralPhysicsCategory.bulletEnemy {
            if let player = contact.bodyA.node as? AstralPlayer {
                player.damage()
                let impactSound = SKAction.playSoundFileNamed("impact00", waitForCompletion: false)
                player.run(impactSound)
            }
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    
}

