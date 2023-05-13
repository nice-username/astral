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
    var polarity: AstralPolarity = .white
    private var targetRestingFrame: Int = 6
    private var initialScene: SKScene
    public var weapons: [AstralWeapon] = []

    // Thruster particles
    var particleSystem: AstralParticleSystem?
    var hitbox : SKShapeNode?
    
    //
    // Initializes the player sprite and sets its properties
    //
    init(scene: SKScene) {
        self.maxHealth = 1
        self.health = 1
        self.initialScene = scene
        let initialTexture = SKTexture(imageNamed: "frame06.png")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        
        self.name                   = "player"
        self.zPosition              = 2
        self.xScale                 = 1.5
        self.yScale                 = 1.5
        self.texture?.filteringMode = .nearest
        self.initPhysics()
        self.initParticles()
        self.loadTextures()
        self.initWeapon()
        
        // Add to scene
        scene.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //
    // Init collision
    //
    private func initPhysics() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = AstralPhysicsCategory.player
        physicsBody?.collisionBitMask = AstralPhysicsCategory.boundary | AstralPhysicsCategory.obstacle
        physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.boundary | AstralPhysicsCategory.bulletEnemy
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
    }
    
    
    
    
    
    //
    // Init weapon
    //
    private func initWeapon() {
        // Default weapon
        // Laser beam weapon
        let laserAmmo = AstralWeaponAmmoType.singleShot
        let defaultWeapon = AstralWeapon(gameScene: self.initialScene,
                                         name: "",
                                         damage: 1,
                                         direction: 90.0,
                                         cooldown: 0.125,
                                         range: 0,
                                         ammoType: laserAmmo,
                                         reloadTime: 6.0,
                                         clipSize: 0,
                                         isBeam: false)
        self.weapons.append(defaultWeapon)
    }
    
    
    
    
    //
    // Draw hitbox sprite
    //
    public func showHitbox() {
        self.hitbox = SKShapeNode(circleOfRadius: self.size.width / 2)
        self.addChild(self.hitbox!)
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
    // Init particles
    //
    private func initParticles() {
        self.particleSystem = AstralParticleSystem(player: self)
        self.particleSystem?.zPosition = 1
        self.addChild(particleSystem!)
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
    
    func update(joystick: AstralJoystick, currentTime: TimeInterval, deltaTime: TimeInterval, holdingFire: Bool = false) {
        // Update position and check for collisions
        if joystick.velocity != nil {
            self.moveBy(joystick.velocity!)
        }
        self.particleSystem!.update(player: self, joystickDirection: joystick.direction)
        for weapon in self.weapons {
            weapon.update(currentTime, deltaTime, holdingFire: holdingFire)
            if !holdingFire {
                weapon.stopFiring()
            }
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
    
    // Handles the player picking up power-ups, and updates the player's weapons or other properties as appropriate
    // func collectPowerUp(_ powerUp: PowerUpType) {
        // Handle the power-up and apply any relevant effects to the player's properties
    // }
    
    // Ouch!
    func damage(amount: Int = 1) {
        // print("You're fucking dead.")
    }
    
    
    // Upgrades the player's current weapon, increasing its power or adding new capabilities
    func upgradeWeapon() {
        // Upgrade the player's weapon and update any relevant properties
    }
}
