//
//  AstralPlayer.swift
//  astral
//
//  Created by Joseph Haygood on 4/29/23.
//

import Foundation
import SpriteKit
import GameplayKit

class AstralPlayer: SKSpriteNode, AstralUnit {
    var health: Int
    var maxHealth: Int
    var movementSpeed: CGFloat = 8.0
    var textures: [SKTexture] = []

    // Properties
    var polarity: AstralPolarity = .white
    private var touchStartPosition: CGPoint?
    private var targetRestingFrame: Int = 6
    public var weapons: [AstralWeapon] = []

    // Thruster particles
    var particleSystem: AstralParticleSystem?
    
    // debug
    var hitbox : SKShapeNode?
    
    
    // Initializes the player sprite and sets its properties
    init(scene: SKScene) {
        self.maxHealth = 1
        self.health = 1
        let initialTexture = SKTexture(imageNamed: "frame06.png")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        
        self.name = "player"
        self.zPosition = 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = AstralPhysicsCategory.player
        physicsBody?.collisionBitMask = AstralPhysicsCategory.boundary | AstralPhysicsCategory.obstacle
        physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.boundary | AstralPhysicsCategory.bulletEnemy
        physicsBody?.linearDamping = 0.5
        physicsBody?.angularDamping = 1.0
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        
        
        self.hitbox = SKShapeNode(circleOfRadius: self.size.width / 2)
        // self.addChild(self.hitbox!)
        
        // Set initial position, size, and other properties
        self.loadTextures()
        
        // Initialize particle system
        self.particleSystem = AstralParticleSystem(player: self)
        self.particleSystem?.zPosition = 1
        self.addChild(particleSystem!)
        
        // Weapon 01
        let defaultAmmo   = AstralWeaponAmmoType.singleShot
        let defaultWeapon = AstralWeapon(gameScene: scene,
                                         name: "Double shot",
                                         damage: 1,
                                         direction: 90.0,
                                         cooldown: 0.08,
                                         range: 300,
                                         ammoType: defaultAmmo,
                                         reloadTime: 4.0,
                                         clipSize: 50 )
        self.weapons.append(defaultWeapon)
        
        // Scaling
        self.xScale = 1.5
        self.yScale = 1.5
        self.texture?.filteringMode = .nearest
        
        // Add to scene
        scene.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Load sprites
    //
    private func loadTextures() {
        let atlas = SKTextureAtlas(named: "AstralPlayer")
        
        for i in 0...12 {
            let textureName = String(format: "frame%02d.png", i)
            let texture = atlas.textureNamed(textureName)
            textures.append(texture)
        }
    }
    
    
    //
    //
    //
    func moveBy(_ vector: CGVector) {
        // print("dx: \(vector.dx), dy: \(vector.dy)")
        let newPosition = CGPoint(x: self.position.x + vector.dx * movementSpeed, y: self.position.y + vector.dy * movementSpeed)
        self.position = newPosition
    }
    
    
    
    //
    // Set the player sprite to one of its textures immediately
    //
    public func setSprite(inputValue: CGFloat) {
        self.removeAction(forKey: "returnToRest")
        let index = Int(round(inputValue * 5)) + 6
        if index >= 0 && index < textures.count {
            self.texture = textures[index]
        } else {
        }
    }

    
    
    
    
    
    
    
    
    //
    // Animate the player back to resting position over time
    //
    func animateToRestingPosition(duration: TimeInterval) {
        let currentTexture = self.texture!
        let currentFrame = textures.firstIndex(of: currentTexture) ?? targetRestingFrame
        let frameDifference = abs(targetRestingFrame - currentFrame)
        let frameDuration = duration / Double(frameDifference)

        let toFrame = currentFrame < targetRestingFrame ? targetRestingFrame + 1 : targetRestingFrame - 1

        var actions: [SKAction] = []
        for i in stride(from: currentFrame, to: toFrame, by: currentFrame < targetRestingFrame ? 1 : -1) {
            let texture = self.textures[i]
            let waitAction = SKAction.wait(forDuration: frameDuration)
            let textureAction = SKAction.run {
                self.texture = texture
            }
            actions.append(waitAction)
            actions.append(textureAction)
        }

        let sequence = SKAction.sequence(actions)
        self.run(sequence,withKey: "returnToRest")
    }

    
    // Called every frame to update the player's position, weapons and thruster jet animation
    func update(currentTime: TimeInterval, deltaTime: TimeInterval) {
        // Unused
    }
    
    func update(joystick: AstralJoystick, currentTime: TimeInterval, deltaTime: TimeInterval) {
        // Update position and check for collisions
        if joystick.velocity != nil {
            self.moveBy(joystick.velocity!)
        }
        self.particleSystem!.update(player: self, joystickDirection: joystick.direction)
        for weapon in self.weapons {
            weapon.update(currentTime, deltaTime)
        }
    }
    
    // Called when the player touches the screen, moves the player sprite
    func move(to touch: UITouch) {
        // Move the player sprite based on the touch position
    }
    
    // Switches the player's polarity, allowing them to absorb or dodge bullets depending on the current polarity
    func switchPolarity() {
        // Switch the player's polarity and update any relevant properties
    }
    
    // Fires the player's current weapon, based on the current polarity and any power-ups that have been collected
    func fireWeapon() {
        // Fire the player's current weapon and apply any relevant power-up effects
        self.weapons[0].fire(unit: self, collider: AstralPhysicsCategory.bulletPlayer)
    }
    
    // Handles the player picking up power-ups, and updates the player's weapons or other properties as appropriate
    // func collectPowerUp(_ powerUp: PowerUpType) {
        // Handle the power-up and apply any relevant effects to the player's properties
    // }
    
    // Ouch!
    func damage(amount: Int = 1) {
        print("You're fucking dead.")
    }
    
    
    // Upgrades the player's current weapon, increasing its power or adding new capabilities
    func upgradeWeapon() {
        // Upgrade the player's weapon and update any relevant properties
    }
}
