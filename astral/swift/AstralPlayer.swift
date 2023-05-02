//
//  AstralPlayer.swift
//  astral
//
//  Created by Joseph Haygood on 4/29/23.
//

import Foundation
import SpriteKit
import GameplayKit

class AstralPlayer: SKSpriteNode {

    // Properties
    var isAbsorbing: Bool = false
    var polarity: Polarity = .white
    private var textures: [SKTexture] = []
    private var touchStartPosition: CGPoint?
    private var targetRestingFrame: Int = 6
    private var weapons: [AstralWeapon] = []

    
    // Weapon properties
    // var currentWeapon: WeaponType = .Basic
    var hasSpreadShot: Bool = false
    var hasPiercingShot: Bool = false
    
    // Power-up properties
    var hasShield: Bool = false
    var shieldTimer: TimeInterval = 0
    
    // Thruster particles
    var particleSystem: AstralParticleSystem?
    
    // debug
    var hitbox : SKShapeNode?
    
    
    // Initializes the player sprite and sets its properties
    init() {
        let initialTexture = SKTexture(imageNamed: "frame06.png")
        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())
        
        self.name = "player"
        self.zPosition = 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = AstralPhysicsCategory.player
        physicsBody?.collisionBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.boundary | AstralPhysicsCategory.bullet
        physicsBody?.contactTestBitMask = AstralPhysicsCategory.enemy | AstralPhysicsCategory.boundary | AstralPhysicsCategory.bullet
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
        
        // Trail shader
        // let trailNode = TrailShaderNode(trailLength: 20.0, color: .white)
        // self.shader = trailNode
        
        // Weapon 01
        let defaultAmmo   = AstralWeaponAmmoType.singleShot
        let defaultWeapon = AstralWeapon(name: "Double shot", damage: 4.0, cooldown: 1.2, range: 300, ammoType: defaultAmmo, reloadTime: 4.0, clipSize: 50)
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
        let movementSpeed: CGFloat = 5.0
        let newPosition = CGPoint(x: self.position.x + vector.dx * movementSpeed, y: self.position.y + vector.dy * movementSpeed)
        self.position = newPosition
    }
    
    
    
    //
    // Set the player sprite to one of its textures immediately
    //
    public func setPlayerSprite(inputValue: CGFloat) {
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


    
    
    
    
    // Called every frame to update the player's position and check for collisions with other objects
    func update(joystick: AstralJoystick) {
        // Update position and check for collisions
        if joystick.velocity != nil {
            self.moveBy(joystick.velocity!)
        }
        self.particleSystem!.update(player: self, joystickDirection: joystick.direction)
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
    }
    
    // Handles the player picking up power-ups, and updates the player's weapons or other properties as appropriate
    // func collectPowerUp(_ powerUp: PowerUpType) {
        // Handle the power-up and apply any relevant effects to the player's properties
    // }
    
    // Upgrades the player's current weapon, increasing its power or adding new capabilities
    func upgradeWeapon() {
        // Upgrade the player's weapon and update any relevant properties
    }
}
