//
//  AstralWeapon.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//

import Foundation
import SpriteKit

class AstralWeapon: SKNode {
    var gameScene: SKScene!
    var damage: Int
    var cooldownTime: TimeInterval
    var cooldownTimeToWait: TimeInterval
    var reloadTime: TimeInterval
    var clipCurrentAmount: Int
    var clipSize: Int
    var range: CGFloat
    var direction: CGFloat
    var ammoType: AstralWeaponAmmoType
    // var soundEffect: SKAction
    var isReloading: Bool = false
    var isCoolingDown: Bool = false
    private var timeSinceLastShot: TimeInterval = 0.0
    private var timeSinceLastReload: TimeInterval = 0.0
    private var lifeTime: TimeInterval = 0.0
    

    init(gameScene: SKScene, name: String, damage: Int, direction: CGFloat, cooldown: TimeInterval, range: CGFloat, ammoType: AstralWeaponAmmoType, reloadTime: TimeInterval, clipSize: Int) {
        self.gameScene = gameScene
        self.damage = damage
        self.direction = direction
        self.cooldownTime = cooldown
        self.cooldownTimeToWait = 0.0
        self.range = range
        self.ammoType = ammoType
        self.reloadTime = reloadTime
        // self.soundEffect = soundEffect
        self.clipCurrentAmount = clipSize
        self.clipSize = clipSize
        super.init()
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Shoot the weapon
    // Create associated sprites and sounds
    //
    func fire(unit: SKSpriteNode, collider: UInt32) {
        if self.canFire() {
            let randomOffset = CGFloat(Int(arc4random_uniform(4)) + 0)
            let spawnPt1     = CGPoint(x: unit.position.x - 24 - randomOffset, y: unit.position.y)
            let spawnPt2     = CGPoint(x: unit.position.x + 24 + randomOffset, y: unit.position.y)
            let bullet       = AstralWeaponAmmoType.singleShot.spawnBullet(at: spawnPt1, direction: self.direction + (randomOffset/2), collider: collider)
            let bullet2      = AstralWeaponAmmoType.singleShot.spawnBullet(at: spawnPt2, direction: self.direction - (randomOffset/2), collider: collider)
            
            // Configure bullet properties here using the weapon's settings and target position
            // ...
            self.gameScene.addChild(bullet)
            self.gameScene.addChild(bullet2)
            self.cooldownTimeToWait = self.cooldownTime
            self.isCoolingDown = true
        }
    }
    
    
    //
    //
    //
    func update(_ currentTime: TimeInterval, _ deltaTime: TimeInterval) {
        if self.cooldownTimeToWait <= 0 {
            self.isCoolingDown = false
            self.cooldownTimeToWait = 0.0
        } else {
            self.cooldownTimeToWait -= deltaTime
        }
    }
    
    
    
    //
    // Are we allowed to shoot?
    //
    public func canFire() -> Bool {
        return !self.isReloading && !self.isCoolingDown
    }

    
    
    //
    // Return the clipCurrentAmount to clipSize
    // Play any associated animations, delays, etc.
    // Reset the reload timer
    //
    func reload() {
        self.isReloading = true
        self.clipCurrentAmount = self.clipSize
        self.timeSinceLastReload = 0.0
    }
}
