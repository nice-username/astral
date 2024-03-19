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
    var warmUpTime: TimeInterval = 0.0
    var warmUpTimeToWait: TimeInterval = 0.0
    var maxFiringTime: TimeInterval = 100.0
    var timeFiring: TimeInterval = 0.0
    var isWarmingUp: Bool = false
    var isFiring: Bool = false
    var isBeam: Bool = false
    public var beam: [SKSpriteNode?] = []
    public var lastUsedUnit: SKSpriteNode?
    public var lastUsedCollider: UInt32 = 0
    private var timeSinceLastShot: TimeInterval = 0.0
    private var timeSinceLastReload: TimeInterval = 0.0
    private var lifeTime: TimeInterval = 0.0
    

    init(gameScene: SKScene, name: String, damage: Int, direction: CGFloat, cooldown: TimeInterval, range: CGFloat, ammoType: AstralWeaponAmmoType, reloadTime: TimeInterval, clipSize: Int, isBeam: Bool = false, warmUpTime: TimeInterval = 2.0) {
        self.gameScene = gameScene
        self.damage = damage
        self.direction = direction
        self.cooldownTime = cooldown
        self.cooldownTimeToWait = 0.0
        self.range = range
        self.ammoType = ammoType
        self.reloadTime = reloadTime
        self.warmUpTime = warmUpTime
        // self.soundEffect = soundEffect
        self.clipCurrentAmount = clipSize
        self.clipSize = clipSize
        self.isBeam = isBeam
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
            if self.isBeam && !self.isFiring && !self.isWarmingUp {
                self.beam = AstralWeaponAmmoType.beamWhite.spawnBeam(collider: collider)
                self.lastUsedCollider = collider
                
                for sprite in beam {
                    unit.addChild(sprite!)
                    sprite?.position.y += 24
                }
                
                self.lastUsedUnit = unit
                self.isWarmingUp = true
                self.warmUpTimeToWait = self.warmUpTime
            } else {
                // print("lol, firin: \(self.isFiring), warmin: \(self.isWarmingUp)")
                let randomOffset = CGFloat(Int(arc4random_uniform(4)) + 0)
                let spawnPt1     = CGPoint(x: unit.position.x - 24 - randomOffset, y: unit.position.y)
                let spawnPt2     = CGPoint(x: unit.position.x + 24 + randomOffset, y: unit.position.y)
                let bullet       = AstralWeaponAmmoType.singleShot.spawnBullet(at: spawnPt1, direction: self.direction + (randomOffset/2), collider: collider)
                let bullet2      = AstralWeaponAmmoType.singleShot.spawnBullet(at: spawnPt2, direction: self.direction - (randomOffset/2), collider: collider)
                self.gameScene.addChild(bullet)
                self.gameScene.addChild(bullet2)
                self.cooldownTimeToWait = self.cooldownTime
                self.isCoolingDown = true
            }
        } else {
            // print("fucken, cd: \(self.isCoolingDown), reload: \(self.isReloading)")
        }
    }
    
    
    func fireShotgunBlast(from unit: SKSpriteNode, direction: CGFloat, spread: CGFloat, bulletsCount: Int, collider: UInt32) {
        let angleIncrement = spread / CGFloat(bulletsCount - 1)
        for i in 0..<bulletsCount {
            let angleAdjustment = CGFloat(i) * angleIncrement - (spread / 2)
            let bulletDirection = direction + angleAdjustment
            let bullet = ammoType.spawnBullet(at: unit.position, direction: bulletDirection, collider: collider)
            gameScene.addChild(bullet)
        }
    }
    	
    
    //
    //
    //
    func stopFiring() {
        self.isFiring           = false
        self.isWarmingUp        = false
        self.timeFiring         = 0
        self.cooldownTimeToWait = 0
        for sprite in beam {
            if sprite != nil {
                sprite!.removeFromParent()
            }
        }
    }
    
    
    
    //
    //
    //
    func update(_ currentTime: TimeInterval, _ deltaTime: TimeInterval, holdingFire: Bool = true) {
        if self.cooldownTimeToWait <= 0 {
            self.isCoolingDown = false
            self.cooldownTimeToWait = 0.0
        } else {
            self.cooldownTimeToWait -= deltaTime
        }
        
        if self.isBeam {
            if self.isWarmingUp && holdingFire {
                self.warmUpTimeToWait -= deltaTime
                if self.warmUpTimeToWait <= 0 {
                    self.isWarmingUp = false
                    self.isFiring    = true
                }
            }
            
            if self.isFiring && holdingFire {
                // TODO: replace with stopBeam()
                if self.timeFiring >= self.maxFiringTime {
                    self.isFiring   = false
                    self.timeFiring = 0
                    self.cooldownTimeToWait = self.cooldownTime
                } else {
                    if self.timeFiring == 0 && self.lastUsedUnit != nil {
                        let beam = self.ammoType.spawnBeam(warmUp: false, collider: self.lastUsedCollider)
                        for sprite in self.beam {
                            sprite?.removeFromParent()
                        }
                        self.beam = beam
                        for sprite in beam {
                            sprite.position.y += 24
                            self.lastUsedUnit!.addChild(sprite)
                        }
                    }
                }
                self.timeFiring += deltaTime
            }
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
