//
//  AstralEnemy.swift
//  astral
//
//  Created by Joseph Haygood on 5/3/23.
//

import Foundation
import SpriteKit


class AstralEnemy: SKSpriteNode, AstralUnit {
    
    // Properties
    var health: Int = 100
    var maxHealth: Int = 100
    var movementSpeed: CGFloat = 5.0
    var textures: [SKTexture] = []
    var texturesWhite: [SKTexture] = []
    var polarity: AstralPolarity = .white
    var particleSystem: AstralParticleSystem?
    var hitbox: SKShapeNode?
    var currentSpriteID: Int = 6
    var weapons: [AstralWeapon] = []
    var orders: [AstralEnemyOrder] = []
    var isShooting: Bool = false
    let joystick: AstralJoystick = AstralJoystick()
    var speedUpChangeTimeLeft: Double = 0.0
    var speedDownChangeTimeLeft: Double = 0.0
    private var targetRestingFrame: Int = 6
    
    // AstralEnemy-specific properties
    // var firingPattern: AstralFiringPattern?
    
    //
    // Initializes the enemy sprite and sets its properties
    //
    init(scene: SKScene, maxHP: Int = 0) {
        self.health    = maxHP
        self.maxHealth = maxHP
        let initialTexture = SKTexture(imageNamed: "enemyFrame06.png")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        
        self.name = "enemy"
        self.zPosition = 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = AstralPhysicsCategory.enemy
        physicsBody?.collisionBitMask = AstralPhysicsCategory.none
        physicsBody?.contactTestBitMask = AstralPhysicsCategory.player | AstralPhysicsCategory.bulletPlayer | AstralPhysicsCategory.laser
        physicsBody?.linearDamping = 0.5
        physicsBody?.angularDamping = 1.0
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        
        
        self.hitbox = SKShapeNode(circleOfRadius: self.size.width / 2)
        // self.addChild(self.hitbox!)
        
        // Set initial position, size, and other properties
        self.textures = self.loadTextures(atlas: "AstralEnemyType00", frameCount: 13, filename: "enemyFrame")
        self.texturesWhite = self.loadTextures(atlas: "AstralEnemyType00Hit", frameCount: 13, filename: "enemyFrameWhite")
        
        // Initialize particle system
        // self.particleSystem = AstralParticleSystem(player: self)
        // self.particleSystem?.zPosition = 1
        // self.addChild(particleSystem!)
        
        // Weapon 01
        let defaultAmmo   = AstralWeaponAmmoType.singleShot
        let defaultWeapon = AstralWeapon(gameScene: scene,
                                         name: "Double shot",
                                         damage: 1,
                                         direction: 270.0,
                                         cooldown: 0.08,
                                         range: 300,
                                         ammoType: defaultAmmo,
                                         reloadTime: 4.0,
                                         clipSize: 50 )
        self.weapons.append(defaultWeapon)
        
        // Scaling
        self.xScale = 1
        self.yScale = 1
        self.texture?.filteringMode = .nearest
        
        // Add to scene
        self.position.y += 900
        scene.addChild(self)
        
        let exampleOrders : [AstralEnemyOrder] = [  
            AstralEnemyOrder(type: .move(.down),        duration: 1.2),
            AstralEnemyOrder(type: .move(.downLeft),    duration: 0),
            AstralEnemyOrder(type: .turnLeft(0.75),     duration: 0.6),
            AstralEnemyOrder(type: .rest(0.75),         duration: 0.0),
            AstralEnemyOrder(type: .fire,               duration: 0.36),
            AstralEnemyOrder(type: .fireStop,           duration: 0.14),
            AstralEnemyOrder(type: .stop,               duration: 0.12),
            AstralEnemyOrder(type: .move(.right),       duration: 0.0),
            AstralEnemyOrder(type: .turnRight(1.5),     duration: 1.25),
            AstralEnemyOrder(type: .stop,               duration: 0.0),
            AstralEnemyOrder(type: .rest(0.75),         duration: 0.75),
            AstralEnemyOrder(type: .move(.upLeft),      duration: 0.0),
            AstralEnemyOrder(type: .turnLeft(0.50),     duration: 0.25),
            AstralEnemyOrder(type: .fire,               duration: 0.50),
            AstralEnemyOrder(type: .fireStop,           duration: 0.0),
            AstralEnemyOrder(type: .rest(0.75),         duration: 0.5),
            AstralEnemyOrder(type: .stop,               duration: 1.0)
        ]
        self.orders = exampleOrders
        self.runOrders()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // AstralUnit methods
    func update(currentTime: TimeInterval, deltaTime: TimeInterval) {
        // Update position and check for collisions
        if self.joystick.normalizedVelocity != nil {
            self.moveBy(direction: self.joystick.direction)
        }
        for weapon in self.weapons {
            weapon.update(currentTime, deltaTime)
        }
        if self.isShooting {
            self.fireWeapon()
        }
        if self.speedUpChangeTimeLeft > 0 {
            self.speedUpChangeTimeLeft -= deltaTime
            self.movementSpeed += 0.02
        }
        if self.speedDownChangeTimeLeft > 0 {
            self.speedDownChangeTimeLeft -= deltaTime
            self.movementSpeed -= 0.02
        }
    }
    
    
    private func loadTextures(atlas: String, frameCount: Int, filename: String, indexLength: Int = 2) -> [SKTexture] {
        var textures: [SKTexture] = []
        let atlas = SKTextureAtlas(named: atlas)
        for i in 0...frameCount - 1 {
            let indexString = String(repeating: "0", count: indexLength - String(i).count) + "\(i)"
            let textureName = "\(filename)\(indexString).png"
            let texture = atlas.textureNamed(textureName)
            textures.append(texture)
        }
        return textures
    }
    
    func fireWeapon() {
        for weapon in self.weapons {
            weapon.fire(unit: self, collider: AstralPhysicsCategory.bulletEnemy)
        }
    }
    
    
    func stop() {
        self.joystick.direction = .none
    }
    
    
    func moveBy(_ vector: CGVector) {
        // Unused
    }
    
    func moveBy(direction: JoystickDirection) {
        let vector      = self.joystick.normalizedVelocity
        let posX        = self.position.x + vector!.dx * movementSpeed
        let posY        = self.position.y + vector!.dy * movementSpeed
        self.position   = CGPoint(x: posX, y: posY)
    }
    
    func takeDamage(amount: Int = 1) {
        // TODO: Replace with appropriate frame
        let hitStr = "enemyFrameWhite\(String(format: "%02d", self.currentSpriteID))"
        let hitSprite = SKSpriteNode(imageNamed: hitStr)
        
        hitSprite.zPosition = 3
        let dy = Double.random(in: 12...24)
        let dx = Double.random(in: -12...12)
        let fadeOutTime = Double.random(in: 0.15...0.4)
        hitSprite.alpha = Double.random(in: 0.2...0.4)
        let action = SKAction.sequence([
            SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 0.2),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.removeFromParent()
        ])
        self.addChild(hitSprite)

        hitSprite.run(action, withKey: "hit")
        
        self.health -= amount
        if self.health <= 0 {
            self.die()
        }
    }

    
    
    
    
    
    //
    // Tell the sprite to play its "turn right" animation over time
    //
    func turnRight(over time: TimeInterval) {
        var ids : [Int] = []
        
        // Stop turning if I was already
        self.removeAction(forKey: "turn")
        
        // Define the textures for the turning animation
        let baseTextureName = "enemyFrame"
        let numFrames = 6
        var turnTextures = [SKTexture]()
        for i in stride(from: numFrames, through: 0, by: -1) {
            let textureName = "\(baseTextureName)\(String(format: "%02d", i)).png"
            let texture = SKTexture(imageNamed: textureName)
            turnTextures.append(texture)
            ids.append(i)
        }
        
        // Calculate the duration for each frame of the animation
        let frameDuration = time / Double(turnTextures.count)
        
        // Create an array of actions to set each texture in turn
        var actions: [SKAction] = []
        for (index, texture) in turnTextures.enumerated() {
            let textureAction = SKAction.setTexture(texture)
            let waitAction = SKAction.wait(forDuration: frameDuration)
            let setSpriteAction = SKAction.run { [weak self] in
                self!.currentSpriteID = ids[index]
            }
            let frameAction = SKAction.sequence([
                textureAction,
                setSpriteAction,
                waitAction
            ])
            actions.append(frameAction)
        }
        
        // Run the action sequence on the enemy node
        let sequence = SKAction.sequence(actions)
        self.run(sequence, withKey: "turn")
    }
    
    
    
    
    //
    // Tell the sprite to play its "turn right" animation over time
    //
    func turnLeft(over time: TimeInterval) {
        var ids : [Int] = []
        
        // Stop turning if I was already
        self.removeAction(forKey: "turn")
        
        // Define the textures for the turning animation
        let baseTextureName = "enemyFrame"
        let numFrames = 6
        var turnTextures = [SKTexture]()
        for i in stride(from: numFrames, through: 12, by: 1) {
            let spriteID    = String(format: "%02d", i)
            let textureName = "\(baseTextureName)\(spriteID).png"
            let texture = SKTexture(imageNamed: textureName)
            turnTextures.append(texture)
            ids.append(i)
        }
        
        // Calculate the duration for each frame of the animation
        let frameDuration = time / Double(turnTextures.count)
        
        // Create an array of actions to set each texture in turn
        var actions: [SKAction] = []
        for (index, texture) in turnTextures.enumerated() {
            let textureAction = SKAction.setTexture(texture)
            let waitAction = SKAction.wait(forDuration: frameDuration)
            let setSpriteAction = SKAction.run { [weak self] in
                self!.currentSpriteID = ids[index]
            }
            let frameAction = SKAction.sequence([
                textureAction,
                setSpriteAction,
                waitAction
            ])
            actions.append(frameAction)
        }
        
        // Run the action sequence on the enemy node
        let sequence = SKAction.sequence(actions)
        self.run(sequence, withKey: "turn")
    }
    
    
    
    //
    // Tell the sprite to return to frame 06 (rest) over time
    //
    func animateToRestingPosition(duration: TimeInterval) {
        // Stop turning if I was already
        self.removeAction(forKey: "turn")
        let currentFrame = self.currentSpriteID
        
        let frameDifference = abs(self.targetRestingFrame - currentFrame)
        let frameDuration = duration / Double(frameDifference)
        let toFrame = currentFrame < self.targetRestingFrame ? self.targetRestingFrame + 1 : self.targetRestingFrame - 1
        
        var actions: [SKAction] = []
        for i in stride(from: currentFrame, to: toFrame, by: currentFrame < self.targetRestingFrame ? 1 : -1) {
            let texture = self.textures[i]
            let waitAction = SKAction.wait(forDuration: frameDuration)
            let textureAction = SKAction.setTexture(texture)
            let setSpriteAction = SKAction.run { [weak self] in
                self!.currentSpriteID = i
            }
            let frameAction = SKAction.sequence([waitAction, textureAction, setSpriteAction])
            actions.append(frameAction)
        }
        
        let sequence = SKAction.sequence(actions)
        self.run(sequence, withKey: "turn")
    }


    
    
    
    //
    // Execute orders
    //
    func runOrders() {
        // Schedule the orders to execute in sequence
        var time: TimeInterval = 0
        for order in self.orders {
            DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
                switch order.type {
                case .move(let direction):
                    self!.joystick.direction = direction
                    
                case .turnRight(let duration):
                    self!.turnRight(over: duration)
                    
                case .turnLeft(let duration):
                    self!.turnLeft(over: duration)
                    
                case .fire:
                    self!.isShooting = true
                    
                case .fireStop:
                    self!.isShooting = false
                    
                case .stop:
                    self!.stop()
                
                case .rest(let duration):
                    self!.animateToRestingPosition(duration: duration)
                    
                case .speedUp(let duration):
                    self!.speedUpChangeTimeLeft = duration
                    
                case .speedDown(let duration):
                    self!.speedDownChangeTimeLeft = duration
                
                default:
                    break
                }
                
                order.completion?()
            }
            time += order.duration
        }
    }

    
    
    
    
    func die() {
        self.removeFromParent()
    }
}
