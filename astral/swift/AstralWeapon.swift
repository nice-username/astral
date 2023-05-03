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
    var damage: CGFloat
    var cooldownTime: TimeInterval
    var cooldownTimeToWait: TimeInterval
    var reloadTime: TimeInterval
    var clipCurrentAmount: Int
    var clipSize: Int
    var range: CGFloat
    var ammoType: AstralWeaponAmmoType
    // var soundEffect: SKAction
    var isReloading: Bool = false
    var isCoolingDown: Bool = false
    private var timeSinceLastShot: TimeInterval = 0.0
    private var timeSinceLastReload: TimeInterval = 0.0
    private var lifeTime: TimeInterval = 0.0
    

    init(gameScene: SKScene, name: String, damage: CGFloat, cooldown: TimeInterval, range: CGFloat, ammoType: AstralWeaponAmmoType, reloadTime: TimeInterval, clipSize: Int) {
        self.gameScene = gameScene
        self.damage = damage
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
    func fire(player: AstralPlayer) {
        if self.canFire() {
            let spawnPt = CGPoint(x: player.position.x, y: player.position.y)
            // let currentTime = CACurrentMediaTime()
            let bullet = AstralWeaponAmmoType.singleShot.spawnBullet(at: spawnPt, target: spawnPt)
            
            // Configure bullet properties here using the weapon's settings and target position
            // ...
            self.gameScene.addChild(bullet)
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
        
        for bullet in self.children {
            if let bullet = bullet as? SKSpriteNode {
                if bullet.position.distanceTo(self.position) > self.ammoType.range {
                    bullet.removeFromParent()
                    continue
                }
                // apply homing behavior if enabled
                if self.ammoType.homing {
                    // ...
                }
            }
        }
    }
    
    
    
    //
    // Are we allowed to shoot?
    //
    private func canFire() -> Bool {
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
