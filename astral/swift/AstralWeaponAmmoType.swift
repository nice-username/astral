//
//  AmmoType.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//

import Foundation
import SpriteKit

/*
enum AmmoType: Int {
    case singleShot         // Straight ahead
    case tripleShot         // 0 / 30 / -30 degree
    case laserBeam          // Straight line splash damage
    case homingMissiles     // Sweep the screen -> launch slow but strong missiles that hone in with splash damage
    case EMP                // Disable enemies / special / elemental
    case flamethrower       // Splash damage in an area
    case grenade            // Splash damage in an area
    case ionCannon          // Elemential / special type (vs. electronics
    case gravity            // Suck enemies into bullets
    case lightning          // Connects to the nearest enemy
    case arcLightning       // Connects to several enemies
    case sonicWave          // Radiates outwards
    case chain              // Connects with nearby enemies
    case waterJet           // Push player backwards -> elemental / special type
    case lockOnLaser        // Sweep the screen like StarFox -> deal large damage
}
*/

class AstralWeaponAmmoType: SKNode {
    let spriteFilename: String
    let damage: CGFloat
    let moveSpeed: CGFloat
    let range: CGFloat
    let spread: CGFloat
    let homing: Bool
    let splash: Bool
    
    
    init(name: String, spriteFilename: String, damage: CGFloat, moveSpeed: CGFloat, range: CGFloat, spread: CGFloat, homing: Bool, splash: Bool) {
        self.spriteFilename = spriteFilename
        self.damage = damage
        self.moveSpeed = moveSpeed
        self.range = range
        self.spread = spread
        self.homing = homing
        self.splash = splash
        super.init()
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnBullet(at point: CGPoint, target: CGPoint) -> SKSpriteNode {
        let bullet = SKSpriteNode(imageNamed: self.spriteFilename)
        bullet.zPosition = 3
        bullet.xScale = 2.0
        bullet.yScale = 2.0
        bullet.texture?.filteringMode = .nearest
        bullet.position = point
        
        // Configure physics properties
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.categoryBitMask = AstralPhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.destructible | AstralPhysicsCategory.obstacle
        bullet.physicsBody?.collisionBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.destructible | AstralPhysicsCategory.obstacle
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.friction = 0
        bullet.physicsBody?.linearDamping = 0.0
        bullet.physicsBody?.angularDamping = 0.0

        
        // Calculate the angle and direction vector
        let angle = CGFloat.pi / 2 // 90 degrees (upwards)
        let direction = CGVector(dx: cos(angle), dy: sin(angle))
        bullet.physicsBody?.velocity = CGVector(dx: direction.dx * self.moveSpeed, dy: direction.dy * self.moveSpeed)

        return bullet
    }
    
    static var singleShot: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Double Shot",
                        spriteFilename: "Bullet00",
                        damage: 4,
                        moveSpeed: 400,
                        range: 50,
                        spread: 0,
                        homing: false,
                        splash: false)
    }
    
    static var tripleShot: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Triple Shot", spriteFilename: "Bullet00", damage: 5, moveSpeed: 20, range: 400, spread: 30, homing: false, splash: false)
    }
    
    // Add more ammo types as needed...
}
