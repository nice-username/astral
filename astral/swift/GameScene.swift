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
    
    override func sceneDidLoad() {
        self.backgroundColor = .black
        
        self.lastUpdateTime = 0
        self.player = AstralPlayer(scene: self)
        
        joystick = AstralJoystick()
        joystick.position = CGPoint(x: frame.minX + (76 * 2.5), y: frame.minY + (76 * 1.5))
        joystick.xScale = 2.0
        joystick.yScale = 2.0
        self.addChild(joystick)
        
        fireButton = SKSpriteNode(imageNamed: "weapon_use_button")
        self.addChild(fireButton)
        fireButton!.xScale = 3
        fireButton!.yScale = 3
        fireButton!.texture?.filteringMode = .nearest
        fireButton.position.x += self.frame.width  / 2.0 - fireButton.size.width  + 32
        fireButton.position.y -= self.frame.height / 2.0 - fireButton.size.height - 200
        
        
        self.parallaxBg = AstralParallaxBackground(size: self.size)
        self.parallaxBg.xScale = 5.0
        self.parallaxBg.yScale = 5.0
        // self.parallaxBg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(self.parallaxBg)
        
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        self.createBoundaries()
    }
    
    
    private func createBoundaries() {
        let xOffset = 80.0
        let bounds = CGRect(x: self.frame.minX + (xOffset / 2.0), y: self.frame.minY, width: self.size.width - xOffset, height: self.size.height)
        let body = SKPhysicsBody(edgeLoopFrom: bounds)
        body.categoryBitMask = AstralPhysicsCategory.boundary
        body.collisionBitMask = AstralPhysicsCategory.boundary
        body.contactTestBitMask = AstralPhysicsCategory.bullet | AstralPhysicsCategory.laser | AstralPhysicsCategory.enemy | AstralPhysicsCategory.player
        
        let hitbox = SKShapeNode(rect: bounds)
        hitbox.lineWidth = 5.0
        self.addChild(hitbox)
        
        self.physicsBody = body
    }

    
    func touchDown(atPoint pos : CGPoint) {
        if !fireButton.contains(pos) {
            self.touchStartPosition = pos
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if(self.touchStartPosition != nil) {
            let currentPosition = pos
            let dx = currentPosition.x - self.touchStartPosition!.x
            let screenWidth = UIScreen.main.bounds.width
            let input = -(dx / screenWidth)
            player!.setPlayerSprite(inputValue: input)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let animationDuration: TimeInterval = 0.4141 // Change this value to adjust the total animation duration
        self.player!.animateToRestingPosition(duration: animationDuration)
        touchStartPosition = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var hitButton = false
        for t in touches {
            if fireButton.contains(t.location(in: self)) {
                hitButton = true
            }
            self.touchDown(atPoint: t.location(in: self))
        }
        if !hitButton {
            self.joystick.touchesBegan(touches, with: event)
        }
        if hitButton {
            self.player?.fireWeapon()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.joystick.touchesMoved(touches, with: event)
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.joystick.touchesEnded(touches, with: event)
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        /*
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        */
        self.parallaxBg.update(dt, joystickDirection: self.joystick.direction)
        self.player?.update(joystick: self.joystick, currentTime: currentTime, deltaTime: dt)
        
        if let normalizedVelocity = joystick.normalizedVelocity, let player = player {
            player.moveBy(normalizedVelocity)
        }
        
        self.lastUpdateTime = currentTime
    }
}
