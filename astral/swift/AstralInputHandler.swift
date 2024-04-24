//
//  AstralInputHandler.swift
//  astral
//
//  Created by Joseph Haygood on 9/5/23.
//

import Foundation
import SpriteKit

class AstralInputHandler {
    private var player: AstralPlayer
    private var scene : SKScene
    private var joystick : AstralJoystick
    private var touchStartPosition: CGPoint?
    private var fireTouch: UITouch?
    private var joystickTouch: UITouch?
    public  var fireButton : SKSpriteNode!          // TODO:  This probably doesn't belong here
    private var holdingDownFire: Bool = false
    weak var delegate: AstralWeaponDelegate?
    
    init(scene: SKScene, player: AstralPlayer, joystick: AstralJoystick) {
        self.scene = scene
        self.player = player
        self.joystick = joystick
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if(self.touchStartPosition != nil) {
            let currentPosition = pos
            let dx = currentPosition.x - self.touchStartPosition!.x
            let screenWidth = UIScreen.main.bounds.width
            let input = -(dx / screenWidth)
            player.setSprite(inputValue: input)
        }
    }
    
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        
        var hitButton = false
        for t in touches {
            let point = t.location(in: scene)
            
            /*
            let b = AstralBulletFactory.createBullet(from:      .shotgunBlast,
                                                     collider:  AstralPhysicsCategory.bulletPlayer,
                                                     position:  point,
                                                     direction: 90,
                                                     scale:     2)
            scene.addChild(b)
            */
            
            /*
            let behavior = AstralBulletMultiShot(numberOfShots: 3, spreadAngleDegrees: 45)
            let angles = behavior.calculateShotAngles(baseDirection: 90)

            for angle in angles {
                let b = AstralBulletFactory.createBullet(from:      .shotgunBlast,
                                                         collider:  AstralPhysicsCategory.bulletPlayer,
                                                         position:  point,
                                                         direction: angle,
                                                         scale:     1)
                b.zPosition = 3
                scene.addChild(b)
            }
            */
            
            
            let b = AstralBulletFactory.createBullet(from:      .homingBullet,
                                                     collider:  AstralPhysicsCategory.bulletPlayer,
                                                     position:  point,
                                                     direction: 90,
                                                     scale:     2)
            b.delegate = self.delegate
            delegate?.addBullet(b)
            
            if fireButton.contains(point) {
                hitButton = true
                self.fireTouch = t
                self.holdingDownFire = true
                let downTexture = SKTexture(imageNamed: "ui_fire_button_down")
                fireButton.texture = downTexture
            } else if self.joystickTouch == nil {
                self.joystickTouch = t
                self.touchStartPosition = point
            }
        }
        
        if !hitButton {
            self.joystick.touchesBegan(touches, with: event)
        } else {
            self.player.weapons[0].fire(unit: self.player, collider: AstralPhysicsCategory.bulletPlayer)
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == self.fireTouch {
            } else if touch == self.joystickTouch {
                self.touchMoved(toPoint: touch.location(in: scene))
                self.joystick.touchesMoved(touches, with: event)
            }
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == fireTouch {
                let upTexture = SKTexture(imageNamed: "ui_fire_button_up")
                fireButton.texture = upTexture
                self.fireTouch = nil
                self.holdingDownFire = false
                self.player.weapons[0].isWarmingUp = false
            } else if touch == self.joystickTouch {
                let animationDuration: TimeInterval = 0.4141
                self.player.animateToRestingPosition(duration: animationDuration)
                self.touchStartPosition = nil
                self.joystickTouch = nil
                self.joystick.touchesEnded(touches, with: event)
            }
        }
    }
        
    
    func update(_ currentTime: TimeInterval, deltaTime: TimeInterval) {
        if self.holdingDownFire && self.player.weapons[0].canFire() {
            self.player.weapons[0].fire(unit: self.player, collider: AstralPhysicsCategory.bulletPlayer)
        }
        
        self.player.update(joystick: self.joystick, currentTime: currentTime, deltaTime: deltaTime, holdingFire: self.holdingDownFire)
                
        if let normalizedVelocity = joystick.normalizedVelocity {
            player.moveBy(normalizedVelocity)
        }
    }
}
