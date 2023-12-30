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
    
    private var state : AstralGameStateManager!
    private var lastUpdateTime : TimeInterval = 0
    private var touchStartPosition: CGPoint?
    private var player : AstralPlayer?
    private var joystick: AstralJoystick!
    private var parallaxBg: AstralParallaxBackground!
    private var fireButton : SKSpriteNode!
    private var holdingDownFire : Bool = false
    private var collisionHandler : AstralCollisionHandler?
    private var input : AstralInputHandler?
    var enemies: [AstralEnemy] = []
    var enemy: AstralEnemy?
    var fireTouch: UITouch?
    var joystickTouch: UITouch?

    
    override func sceneDidLoad() {
        self.state = AstralGameStateManager.shared
        
        self.backgroundColor = .black
        self.collisionHandler = AstralCollisionHandler()
        
        self.lastUpdateTime = 0
        self.player = AstralPlayer(scene: self)
        self.addChild(player!)
        player?.xScale = 1.5
        player?.yScale = 1.5
        player?.texture?.filteringMode = .nearest
        
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
        self.parallaxBg.position = CGPoint(x: 0, y: self.size.height / 2)
        self.addChild(self.parallaxBg)
        
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        self.createBoundaries()
        
        // test dialog
        /*
            let speaker = AstralDialogSpeaker(at: CGPoint(x: -150.0, y: -472.0))
            let test1   = AstralDialogSmall(dialogText: "host", dialogWidth: 7.0)
            let test2   = AstralDialogSmall(dialogText: "status", dialogWidth: 46.0)
            let test3   = AstralDialogSmall(dialogText: "connection", dialogWidth: 65.0)
            let test4   = AstralDialogSmall(dialogText: "frequency", dialogWidth: 62.0)
            self.addChild(test1)
            self.addChild(test2)
            self.addChild(test3)
            self.addChild(test4)
            self.addChild(speaker)
                    
            test2.position.y -= 48.0
            test3.position.y -= 96.0
            test4.position.y -= 144.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                test1.extendWidthTo(targetWidth: 34.0, overTime: 0.250)
            }
        */
        
        let textIntro = ["", "Wow that's so long lmfaooo"]
        let textBox = AstralDialogTextBox(scale: 4.0,
                                          backgroundSpriteName: "DialogTextBox00",
                                          textPages: textIntro,
                                          font: "BitPotion",
                                          charDisplayDuration: 0.075, arrowSpriteName: "DialogArrow")
        self.addChild(textBox)
         
        
        let font = AstralBitmapFont(font: "munro_bitmap")
        let label = font.createLabel(withText: "Yeah we're hella writing text af lmao", maxWidth: 400.0, soundFileName: "blip")
        self.addChild(label)
        label.zPosition = 4
        label.position = CGPoint(x: -200, y: 32.0)
        
        self.input = AstralInputHandler(scene: self, player: player!, joystick: joystick)
        input?.fireButton = self.fireButton
        
        self.size = CGSize(width: 750.0, height: 1334.0)
        print("w: \(self.frame.width), h:\(self.frame.height)")
    }

    
    private func createBoundaries() {
        let xOffset = 80.0
        let bounds = CGRect(x: self.frame.minX + (xOffset / 2.0), y: self.frame.minY, width: self.size.width - xOffset, height: self.size.height)
        let body = SKPhysicsBody(edgeLoopFrom: bounds)
        body.categoryBitMask = AstralPhysicsCategory.boundary
        body.collisionBitMask = AstralPhysicsCategory.boundary
        body.contactTestBitMask = AstralPhysicsCategory.bulletPlayer | AstralPhysicsCategory.bulletEnemy | AstralPhysicsCategory.enemy | AstralPhysicsCategory.player
        
        // let hitbox = SKShapeNode(rect: bounds)
        // hitbox.lineWidth = 5.0
        // self.addChild(hitbox)
        
        self.physicsBody = body
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.collisionHandler?.handleContact(contact: contact)
    }
    
    
    
    //
    // Pass all of the gameplay input to a separate file to be dealt with over there...
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        input!.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        input!.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        input!.touchesEnded(touches, with: event)
    }
    
    
    

    
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime
        
        if self.parallaxBg != nil {
            self.parallaxBg.update(dt, joystickDirection: self.joystick.direction)
        }
        input?.update(currentTime, deltaTime: dt)
        
        for e in enemies {
            e.update(currentTime: currentTime, deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
