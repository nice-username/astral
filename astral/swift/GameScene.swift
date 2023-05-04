//
//  GameScene.swift
//  astral
//      - IKARUGA clone lol
//
//  Created by Joseph Haygood on 4/29/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var entities = [GKEntity]()
    // var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var touchStartPosition: CGPoint?
    private var player : AstralPlayer?
    private var joystick: AstralJoystick!
    private var parallaxBg: AstralParallaxBackground!
    private var fireButton : SKSpriteNode!
    private var holdingDownFire : Bool = false
    private var collisionHandler : AstralCollisionHandler?
    var enemy: AstralEnemy?
    var fireTouch: UITouch?
    var joystickTouch: UITouch?

    
    override func sceneDidLoad() {
        self.backgroundColor = .black
        self.collisionHandler = AstralCollisionHandler()
        
        self.lastUpdateTime = 0
        self.player = AstralPlayer(scene: self)
        self.collisionHandler?.player = self.player
        
        joystick = AstralJoystick()
        self.addChild(joystick)
        
        fireButton = SKSpriteNode(imageNamed: "weapon_use_button")
        self.addChild(fireButton)
        fireButton!.xScale = 3
        fireButton!.yScale = 3
        fireButton!.texture?.filteringMode = .nearest
        fireButton.position.x += self.frame.width  / 2.0 - fireButton.size.width  + 32
        fireButton.position.y -= self.frame.height / 2.0 - fireButton.size.height - 360
        
        
        self.parallaxBg = AstralParallaxBackground(size: self.size)
        self.parallaxBg.xScale = 5.0
        self.parallaxBg.yScale = 5.0
        // self.parallaxBg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(self.parallaxBg)
        
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        self.createBoundaries()
        
        
        self.enemy = AstralEnemy(scene: self, maxHP: 80)
        
        
        // Init audio .. ?
        let audio1 = SKAction.playSoundFileNamed("impact00",waitForCompletion: false)
        self.run(audio1)
    }
    
    
    private func createBoundaries() {
        let xOffset = 80.0
        let bounds = CGRect(x: self.frame.minX + (xOffset / 2.0), y: self.frame.minY, width: self.size.width - xOffset, height: self.size.height)
        let body = SKPhysicsBody(edgeLoopFrom: bounds)
        body.categoryBitMask = AstralPhysicsCategory.boundary
        body.collisionBitMask = AstralPhysicsCategory.boundary
        body.contactTestBitMask = AstralPhysicsCategory.bulletPlayer | AstralPhysicsCategory.bulletEnemy | AstralPhysicsCategory.enemy | AstralPhysicsCategory.player
        
        let hitbox = SKShapeNode(rect: bounds)
        hitbox.lineWidth = 5.0
        // self.addChild(hitbox)
        
        self.physicsBody = body
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if(self.touchStartPosition != nil) {
            let currentPosition = pos
            let dx = currentPosition.x - self.touchStartPosition!.x
            let screenWidth = UIScreen.main.bounds.width
            let input = -(dx / screenWidth)
            player!.setSprite(inputValue: input)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.collisionHandler?.handleContact(contact: contact)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var hitButton = false
        for t in touches {
            let point = t.location(in: self)
            if fireButton.contains(point) {
                hitButton = true
                self.fireTouch = t
                self.holdingDownFire = true
            } else {
                guard let touch = touches.first else { return }
                self.joystickTouch = t
                self.touchStartPosition = point
            }
        }
        
        if !hitButton {
            self.joystick.touchesBegan(touches, with: event)
        } else {
            self.player?.fireWeapon()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.fireTouch {
                // The touch is on the fire button
            } else if touch == self.joystickTouch {
                self.touchMoved(toPoint: touch.location(in: self))
                self.joystick.touchesMoved(touches, with: event)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == fireTouch {
                // The touch ended on the fire button
                // player?.releaseFireButton()
                self.fireTouch = nil
                self.holdingDownFire = false
            } else if touch == self.joystickTouch {
                let animationDuration: TimeInterval = 0.4141 // Change this value to adjust the total animation duration
                self.player!.animateToRestingPosition(duration: animationDuration)
                touchStartPosition = nil
                self.joystickTouch = nil
                self.joystick.touchesEnded(touches, with: event)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        if self.holdingDownFire && self.player!.weapons[0].canFire() {
            self.player!.weapons[0].fire(unit: self.player!, collider: AstralPhysicsCategory.bulletPlayer)
        }
        self.parallaxBg.update(dt, joystickDirection: self.joystick.direction)
        self.player?.update(joystick: self.joystick, currentTime: currentTime, deltaTime: dt)
        self.enemy?.update(currentTime: currentTime, deltaTime: dt)
        
        if let normalizedVelocity = joystick.normalizedVelocity, let player = player {
            player.moveBy(normalizedVelocity)
        }
        
        self.lastUpdateTime = currentTime
    }
}
