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
    let spriteFilename: String?
    let damage: CGFloat
    let moveSpeed: CGFloat
    let range: CGFloat
    let spread: CGFloat
    let homing: Bool
    let splash: Bool
    let warmUpAtlasName: String?
    let firingAtlasName: String?
    var warmUpTextures: [SKTexture] = []
    var firingTextures: [SKTexture] = []
    var warmUpAnim: SKAction?
    var firingAnim: SKAction?
    var impactAtlasName: String?
    var impactTextures: [SKTexture] = []
    var impactAnim: SKAction?
    let isAnimated: Bool
    
    init(name: String, spriteFilename: String? = nil, warmUpAtlasName: String? = nil, firingAtlasName: String? = nil, impactAtlasName: String? = nil, damage: CGFloat, moveSpeed: CGFloat, range: CGFloat, spread: CGFloat, homing: Bool, splash: Bool, isAnimated: Bool = false) {
        self.spriteFilename = spriteFilename
        self.damage = damage
        self.moveSpeed = moveSpeed
        self.range = range
        self.spread = spread
        self.homing = homing
        self.splash = splash
        self.warmUpAtlasName = warmUpAtlasName
        self.firingAtlasName = firingAtlasName
        self.impactAtlasName = impactAtlasName
        self.isAnimated = isAnimated
        
        super.init()
        self.name = name
        self.initializeWarmUp()
        self.initializeFiring()
        self.initializeImpact()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //
    // Use bullet type weapon
    //
    func spawnBullet(at point: CGPoint, direction: CGFloat, collider: UInt32) -> SKSpriteNode {
        let bullet = isAnimated ? initAnimatedBulletSprite(at: point) : initBulletSprite(at: point)
        self.initBulletPhysics(bullet: bullet, collider: collider)
        
        // Stretch a random amount verticall
        // bullet.yScale = Double.random(in: 2.0...4.0)

        // Convert the angle from degrees to radians
        let angleInRadians = direction * CGFloat.pi / 180.0

        // Calculate the direction vector
        let directionVector = CGVector(dx: cos(angleInRadians), dy: sin(angleInRadians))

        // Calculate the speed with a random offset
        let randomOffset = CGFloat(Int(arc4random_uniform(500)) + 100)
        let speed        = self.moveSpeed + randomOffset

        // Set the velocity of the bullet
        bullet.physicsBody?.velocity = CGVector(dx: directionVector.dx * speed, dy: directionVector.dy * speed)
        bullet.userData = ["impactAnim": self.impactAnim!]
        
        return bullet
    }
    
    private func initAnimatedBulletSprite(at point: CGPoint) -> SKSpriteNode {
        let bullet = SKSpriteNode()
        bullet.position = point
        
        guard let atlasName = self.spriteFilename else {
            print("Sprite filename is nil")
            return bullet
        }
        
        let atlas = SKTextureAtlas(named: atlasName)
        let textureNames = atlas.textureNames.sorted()
        
        if textureNames.isEmpty {
            print("No textures found in atlas: \(atlasName)")
            return bullet
        }
        
        let textures = textureNames.map { atlas.textureNamed($0) }
        bullet.texture = textures.first // Set the first frame as the initial texture
        bullet.size = textures.first!.size() // Set size based on the first texture
        
        let animation = SKAction.animate(with: textures, timePerFrame: 1 / 15.0)
        let loopAnimation = SKAction.repeatForever(animation)
        bullet.run(loopAnimation)
        
        return bullet
    }


    
    
    //
    // Use beam type weapon
    //
    func spawnBeam(length: Int = 8, warmUp: Bool = true, collider: UInt32) -> [SKSpriteNode] {
        var textures: [SKTexture] = []
        if warmUp {
            textures = self.warmUpTextures
        } else {
            textures = self.firingTextures
        }
        
        var segments: [SKSpriteNode] = []
        var yOffset: CGFloat = 0.0
        for _ in 0 ... length - 1 {
            let shuffledTextures = textures.shuffled()
            let anim = SKAction.animate(with: shuffledTextures, timePerFrame: 0.0625)
            let sprite = SKSpriteNode(texture: textures[0])
            sprite.texture?.filteringMode = .nearest
            sprite.position.y += yOffset
            let loopAnim = SKAction.repeatForever(anim)
            sprite.run(loopAnim)
            segments.append(sprite)
            yOffset += sprite.size.height
        }
        return segments
    }

    
    
    
    private func initBulletSprite(at point: CGPoint) -> SKSpriteNode {
        let bullet = SKSpriteNode(imageNamed: self.spriteFilename!)
        bullet.zPosition = 3
        bullet.xScale = 2.0
        bullet.yScale = 2.0
        bullet.texture?.filteringMode = .nearest
        bullet.position = point
        bullet.userData = [:]
        return bullet
    }
    
    
    private func initBulletPhysics(bullet: SKSpriteNode, collider: UInt32) {
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.categoryBitMask = collider
        bullet.physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.destructible | AstralPhysicsCategory.obstacle
        bullet.physicsBody?.collisionBitMask = AstralPhysicsCategory.none
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.friction = 0
        bullet.physicsBody?.linearDamping = 0.0
        bullet.physicsBody?.angularDamping = 0.0
    }
    
    
    private func initializeWarmUp() {
        guard let atlasName = self.warmUpAtlasName else { return }
        let atlas = SKTextureAtlas(named: atlasName)
        let sortedNames = atlas.textureNames.sorted()
        self.warmUpTextures = sortedNames.map { atlas.textureNamed($0) }
    }
    
    
    private func initializeImpact() {
        guard let atlasName = self.impactAtlasName else { return }
        let atlas = SKTextureAtlas(named: atlasName)
        self.impactTextures = atlas.textureNames.sorted().map { atlas.textureNamed($0) }
        self.impactAnim = SKAction.animate(with: self.impactTextures, timePerFrame: 1 / 15.0, resize: false, restore: false)
    }
    

    private func initializeFiring() {
        guard let atlasName = self.firingAtlasName else { return }
        let atlas = SKTextureAtlas(named: atlasName)
        let sortedNames = atlas.textureNames.sorted()
        self.firingTextures = sortedNames.map { atlas.textureNamed($0) }
    }
    
    
    static var singleShot: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Double Shot",
                        spriteFilename: "Bullet01",
                        impactAtlasName: "Bullet01Impact",
                        damage: 4,
                        moveSpeed: 800,
                        range: 0,
                        spread: 0,
                        homing: false,
                        splash: false)
    }
    
    
    static var beamWhite: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Beam",
                        warmUpAtlasName: "BeamWhite02WarmUp",
                        firingAtlasName: "BeamWhite00",
                        damage: 1,
                        moveSpeed: 0,
                        range: 0,
                        spread: 0,
                        homing: false,
                        splash: false)
    }
    
    static var tripleShot: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Triple Shot", spriteFilename: "Bullet00", damage: 5, moveSpeed: 20, range: 400, spread: 30, homing: false, splash: false)
    }
    
    static var shotgunBlast: AstralWeaponAmmoType {
        return AstralWeaponAmmoType(name: "Shotgun Blast",
                                    spriteFilename: "Bullet03",
                                    impactAtlasName: "Bullet01Impact",
                                    damage: 3,
                                    moveSpeed: 50,
                                    range: 300,
                                    spread: 5,
                                    homing: false,
                                    splash: false,
                                    isAnimated: true)
    }
    
    
    func handleBulletImpact(bullet: SKSpriteNode) {
        guard let impactAnim = self.impactAnim else {
            bullet.removeFromParent()
            return
        }
        
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([impactAnim, removeAction])
        bullet.run(sequence)
    }
    
}
