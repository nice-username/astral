//
//  MainMenuScene.swift
//  astral
//
//  Created by Joseph Haygood on 6/18/23.
//

import Foundation
import SpriteKit



struct AstralMenuItem {
    let labelNode: SKLabelNode
    let action: (() -> Void)?
    var isLocked: Bool
    let lockedText: String?
}


class AstralMainMenuScene: SKScene {
    var state: AstralGameStateManager?
    var logo: SKSpriteNode!
    var newGameButtonNode: SKLabelNode!
    var continueButtonNode: SKLabelNode!
    var optionsButtonNode: SKLabelNode!
    var cursorNode: SKSpriteNode!
    var bgNode : SKSpriteNode!
    var cursorFrames: [SKTexture] = []


    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        // Add a background image
        let backgroundNode = SKSpriteNode(imageNamed: "MainMenuBackground")
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height)
        backgroundNode.xScale = 2.0
        backgroundNode.yScale = 2.0
        backgroundNode.texture?.filteringMode = .nearest
        backgroundNode.alpha = 0.5
        backgroundNode.zPosition = -1
        self.bgNode = backgroundNode
        addChild(backgroundNode)
        
        // Add a game logo
        let logoNode = SKSpriteNode(imageNamed: "logo1")
        logoNode.position = CGPoint(x: size.width/2, y: size.height*0.75)
        logoNode.xScale = 3.0
        logoNode.yScale = 3.0
        logoNode.texture?.filteringMode = .nearest
        addChild(logoNode)
        
        AstralEffectsManager.shared.displaceSpriteAnimated(for: logoNode)
        
        // Add menu buttons
        newGameButtonNode = createButton(withText: "New Game",
                                         position: CGPoint(x: size.width / 2,
                                                           y: size.height * 0.5) )
        addChild(newGameButtonNode)

        continueButtonNode = createButton(withText: "Continue",
                                          position: CGPoint(x: size.width / 2,
                                                            y: size.height * 0.45) )
        addChild(continueButtonNode)

        optionsButtonNode = createButton(withText: "Options",
                                         position: CGPoint(x: size.width / 2,
                                                           y: size.height * 0.4) )
        addChild(optionsButtonNode)
        
        // Add menu selection cursor
        self.loadCursorAnimation()
        self.cursorNode = SKSpriteNode(texture: self.cursorFrames[0])
        cursorNode.position.x = newGameButtonNode.position.x - 115
        cursorNode.position.y = newGameButtonNode.position.y + (cursorNode.size.height / 2) + 3
        cursorNode.xScale = 2.0
        cursorNode.yScale = 2.0
        cursorNode.texture?.filteringMode = .nearest
        animateCursor()
        addChild(cursorNode)
    }
    
    func createButton(withText text: String, position: CGPoint) -> SKLabelNode {
        let buttonNode = SKLabelNode(fontNamed: "VisitorTT1BRK")
        buttonNode.text = text
        buttonNode.fontSize = 40
        buttonNode.fontColor = SKColor.white
        buttonNode.position = position
        return buttonNode
    }
    

    func loadCursorAnimation() {
        let cursorAnimatedAtlas = SKTextureAtlas(named: "MenuCursor")
        var frames: [SKTexture] = []
        
        let numImages = cursorAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let cursorTextureName = "MenuCursor\(i)"
            frames.append(cursorAnimatedAtlas.textureNamed(cursorTextureName))
        }
        cursorFrames = frames
    }
    
    func animateCursor() {
        cursorNode.run(SKAction.repeatForever(
            SKAction.animate(with: cursorFrames, timePerFrame: 0.1, resize: false, restore: true)
        ))
    }
    
    func menuItem(atPoint point: CGPoint) -> SKNode? {
        let nodes = self.nodes(at: point)
        if nodes.contains(newGameButtonNode) {
            return newGameButtonNode
        } else if nodes.contains(continueButtonNode) {
            return continueButtonNode
        } else if nodes.contains(optionsButtonNode) {
            return optionsButtonNode
        }
        return nil
    }
    
    
    func createTrailAction(to destination: CGPoint, duration: TimeInterval) -> SKAction {
        let action = SKAction.customAction(withDuration: duration) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            
            // Calculate the current position along the path
            let progress = CGFloat(Float(elapsedTime) / Float(duration))
            let currentPosition = CGPoint(x: self.cursorNode.position.x + (destination.x - self.cursorNode.position.x) * progress,
                                          y: self.cursorNode.position.y + (destination.y - self.cursorNode.position.y) * progress)
            
            // Create the trail sprite at the current position
            let trailNode = SKSpriteNode(texture: self.cursorNode.texture)
            trailNode.position = currentPosition
            trailNode.zPosition = 0
            trailNode.xScale = 2.0
            trailNode.yScale = 2.0
            trailNode.texture?.filteringMode = .nearest
            self.addChild(trailNode)
            
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            trailNode.run(SKAction.sequence([fadeOutAction, removeAction]))
        }
        
        return action
    }
    
    /*
    func updateLabels(selectedIndex: Int) {
        for (index, label) in menuLabels.enumerated() {
            if index == selectedIndex {
                label.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
            } else {
                label.run(SKAction.fadeAlpha(to: 0.5, duration: 0.2))
            }
        }
    }
    */


    
    func moveCursor(to node: SKNode) {
        let newPoint = CGPoint(x: node.position.x - 115,
                               y: node.position.y + (cursorNode.size.height / 2) - 3)
        let moveAction = SKAction.move(to: newPoint, duration: 0.2)
        let trailAction = createTrailAction(to: newPoint, duration: 0.2)
        cursorNode.run(SKAction.group([moveAction, trailAction]))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let menuItem = menuItem(atPoint: location) {
            moveCursor(to: menuItem)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Scroll the backgrounds
        self.bgNode.position.y -= 0.5
        
        // loop
        if self.bgNode.position.y < -self.bgNode.size.height / 2 {
            self.bgNode.position.y = self.bgNode.position.y + self.bgNode.size.height
        }
    }
}

