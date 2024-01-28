//
//  AstralEnemy.swift
//  astral
//
//  Created by Joseph Haygood on 5/3/23.
//

import Foundation
import SpriteKit

enum TextureNamingStyle {
    case numberedSequence(frameCount: Int, prefix: String, indexLength: Int)
    case angleSequence
}


class AstralEnemy: SKSpriteNode, AstralUnit {
    let id: UUID
    var atlasName: String
    
    // Properties
    var health: Int = 100
    var maxHealth: Int = 100
    var movementSpeed: CGFloat = 150.0
    var textures: [SKTexture] = []
    var texturesWhite: [SKTexture] = []
    var polarity: AstralPolarity = .white
    var particleSystem: AstralParticleSystem?
    var hitbox: SKShapeNode?
    var currentSpriteID: Int = 0
    var weapons: [AstralWeapon] = []
    var orders: [AstralEnemyOrder] = []
    var isShooting: Bool = false
    let joystick: AstralJoystick = AstralJoystick()
    var speedUpChangeTimeLeft: Double = 0.0
    var speedDownChangeTimeLeft: Double = 0.0
    private var targetRestingFrame: Int = 6
    var currentPath: AstralStageEditorPath?
    
    // AstralEnemy-specific properties
    // var firingPattern: AstralFiringPattern?
    
    //
    // Initializes the enemy sprite and sets its properties
    //
    init(scene: SKScene, config: AstralEnemyConfiguration) {
        self.id = UUID()
        self.health    = config.health
        self.maxHealth = config.maxHealth
        self.atlasName = config.atlasName
        self.textures  = config.textures
        
        let initialTexture = config.textures[0]
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        
        self.name = "enemy"
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        
        physicsBody?.categoryBitMask    = AstralPhysicsCategory.enemy
        physicsBody?.collisionBitMask   = AstralPhysicsCategory.none
        physicsBody?.contactTestBitMask = AstralPhysicsCategory.player |
                                          AstralPhysicsCategory.bulletPlayer |
                                          AstralPhysicsCategory.laser
        physicsBody?.linearDamping = 0.5
        physicsBody?.angularDamping = 1.0
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        
        
        self.hitbox = SKShapeNode(circleOfRadius: self.size.width / 2)
        // self.addChild(self.hitbox!)
        
        // Weapon
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
        self.xScale = 1.0
        self.yScale = 1.0
        self.texture?.filteringMode = .nearest
        
        // Add to scene
        scene.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = UUID()
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
    
    

    static func loadTextures(fromAtlasNamed atlasName: String, namingStyle: TextureNamingStyle) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: atlasName)
        var textures: [SKTexture] = []
        
        switch namingStyle {
        case .numberedSequence(let frameCount, let prefix, let indexLength):
            for i in 0..<frameCount {
                let indexString = String(format: "%0\(indexLength)d", i)
                let textureName = "\(prefix)\(indexString)"
                let texture = atlas.textureNamed(textureName)
                textures.append(texture)
            }
            
        case .angleSequence:
            let angles = stride(from: 0, through: 345, by: 15)
            for angle in angles {
                let textureName = "render_\(angle)"
                let texture = atlas.textureNamed(textureName)
                textures.append(texture)
            }
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
    
    func moveBy(direction: AstralDirection) {
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
    func turnRight(over time: TimeInterval, turnAngle: Int) {
        // Stop any existing turn animation
        self.removeAction(forKey: "turn")
        
        let startSpriteID = self.currentSpriteID
        let spriteCount = self.textures.count
        // Calculate turnSteps as before
        let turnSteps = (turnAngle + 14) / 15
        
        // Generate the sequence of sprite IDs for the turn
        var ids: [Int] = []
        for i in 0..<turnSteps {
            let newSpriteID = (startSpriteID + i + 1) % spriteCount // Adjusted to include the final sprite
            ids.append(newSpriteID)
        }
        
        print("Sprite IDs for turnRight: \(ids)")
        for id in ids {
            print("Texture name for ID \(id): \(self.textures[id].description)")
        }
        
        // Retrieve corresponding textures for the turn
        let turnTextures = ids.map { self.textures[$0] }
        
        // Calculate the duration for each frame of the animation
        let frameDuration = time / Double(turnTextures.count)
        
        // Create an array of actions to set each texture in turn
        var actions: [SKAction] = []
        for (index, texture) in turnTextures.enumerated() {
            let textureAction = SKAction.setTexture(texture)
            let waitAction = SKAction.wait(forDuration: frameDuration)
            let setSpriteAction = SKAction.run { [weak self] in
                self?.currentSpriteID = ids[index]
            }
            let frameAction = SKAction.sequence([textureAction, setSpriteAction, waitAction])
            actions.append(frameAction)
        }
        
        // Run the action sequence on the enemy node
        let sequence = SKAction.sequence(actions)
        self.run(sequence, withKey: "turn")
    }

    
    
    // Needed to comply to protocol
    func moveBy(_ vector: CGVector) {
    }
    
    
    func turn(direction: AstralEnemyOrder.AstralEnemyActionType, duration: TimeInterval, angle: CGFloat) {
        switch direction {
        case .turnLeft:
            turnLeft(over: duration, turnAngle: Int(angle))
        case .turnRight:
            turnRight(over: duration, turnAngle: Int(angle))
        case .turnToBase:
            animateToRestingPosition(duration: duration)
        default:
            break
        }
    }
    
        
    //
    // Tell the sprite to play its "turn right" animation over time
    //
    func turnLeft(over time: TimeInterval, turnAngle: Int) {
        // Stop any existing turn animation
        self.removeAction(forKey: "turn")
        
        let startSpriteID = self.currentSpriteID
        let spriteCount = self.textures.count
        // Calculate turnSteps as before
        let turnSteps = (turnAngle + 14) / 15
        
        // Generate the sequence of sprite IDs for the turn
        var ids: [Int] = []
        for i in 0..<turnSteps {
            let newSpriteID = (startSpriteID - (i + 1) + spriteCount) % spriteCount
            ids.append(newSpriteID)
        }
        
        print("Sprite IDs for turnLeft: \(ids)")
        for id in ids {
            print("Texture name for ID \(id): \(self.textures[id].description)")
        }
        
        // Retrieve corresponding textures for the turn
        let turnTextures = ids.map { self.textures[$0] }
        
        // Calculate the duration for each frame of the animation
        let frameDuration = time / Double(turnTextures.count)
        
        // Create an array of actions to set each texture in turn
        var actions: [SKAction] = []
        for (index, texture) in turnTextures.enumerated() {
            let textureAction = SKAction.setTexture(texture)
            let waitAction = SKAction.wait(forDuration: frameDuration)
            let setSpriteAction = SKAction.run { [weak self] in
                self?.currentSpriteID = ids[index]
            }
            let frameAction = SKAction.sequence([textureAction, setSpriteAction, waitAction])
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
    // For moving along a given path
    //
    private func calculateMovementDuration(from startPoint: CGPoint, to endPoint: CGPoint, speed: CGFloat) -> TimeInterval {
        let distance = startPoint.distanceTo(endPoint)
        return TimeInterval(distance / speed)
    }
    
    func followPath(_ path: AstralStageEditorPath) {
        var actions: [SKAction] = []

        for segment in path.segments {
            switch segment.type {
            case .line(let start, let end):
                let duration = calculateMovementDuration(from: start, to: end, speed: movementSpeed)
                let moveAction = SKAction.move(to: end, duration: duration)
                actions.append(moveAction)
            case .bezier(let start, let control1, let control2, let end):
                let bezierPath = UIBezierPath()
                bezierPath.move(to: start)
                bezierPath.addCurve(to: end, controlPoint1: control1, controlPoint2: control2)
                let duration = calculateMovementDuration(from: start, to: end, speed: movementSpeed)
                let followCurveAction = SKAction.follow(bezierPath.cgPath, asOffset: false, orientToPath: true, duration: duration)
                actions.append(followCurveAction)
            }
            // Add behavior actions here based on nodes or other criteria
        }

        let sequence = SKAction.sequence(actions)
        self.run(sequence)
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
                    
                case .turnRight(let duration, let angle):
                    self!.turnRight(over: duration, turnAngle: Int(angle))
                    
                case .turnLeft(let duration, let angle):
                    self!.turnLeft(over: duration, turnAngle: Int(angle))
                    
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
            }
            time += order.duration
        }
    }

    
    
    func isCloseEnough(to node: AstralPathNode, triggerDistance: CGFloat = 10.0) -> Bool {
        return self.position.distanceTo(node.position) <= triggerDistance
    }
    
    
    func die() {
        (self.scene as? AstralStageEditor)?.removeEnemy(self)
    }
}
