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
            if let bulletNode = contact.bodyA.node as? SKSpriteNode {
                if let action = bulletNode.userData?["impactAnim"] as? SKAction {
                    let removeAction = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([action, removeAction])
                    bulletNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    bulletNode.run(sequence)
                    bulletNode.texture = SKTexture(imageNamed: "Bullet01Impact1")
                    bulletNode.zPosition = 10
                    bulletNode.xScale = 10.0
                    bulletNode.yScale = 5.0
                    bulletNode.texture?.filteringMode = .nearest
                }
            }
            if let enemyNode = contact.bodyB.node as? AstralEnemy {
                enemyNode.takeDamage()
            }
        } else if cat1 == AstralPhysicsCategory.enemy && cat2 == AstralPhysicsCategory.bulletPlayer {
            var dmg = player!.weapons[0].damage
            if let enemyNode = contact.bodyA.node as? AstralEnemy {
                enemyNode.takeDamage(amount: dmg)
                // let impactSound = SKAction.playSoundFileNamed("impact00", waitForCompletion: false)
                // enemyNode.run(impactSound)
            }
            
            if let bulletNode = contact.bodyB.node as? SKSpriteNode {
                if let action = bulletNode.userData?["impactAnim"] as? SKAction {
                    let removeAction = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([action, removeAction])
                    bulletNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    bulletNode.run(sequence)
                    bulletNode.texture = SKTexture(imageNamed: "Bullet01Impact1")
                    bulletNode.zPosition = 10
                    bulletNode.xScale = 10.0
                    bulletNode.yScale = 5.0
                    bulletNode.texture?.filteringMode = .nearest
                }
            }
            
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
            if let bulletNode = contact.bodyB.node as? SKSpriteNode,
               let ammoType = bulletNode.userData?["ammoType"] as? AstralWeaponAmmoType {
                ammoType.handleBulletImpact(bullet: bulletNode)
            }
        }
        
    }
}

