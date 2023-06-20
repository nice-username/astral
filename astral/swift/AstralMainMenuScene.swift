//
//  MainMenuScene.swift
//  astral
//
//  Created by Joseph Haygood on 6/18/23.
//

import Foundation
import SpriteKit


class AstralMainMenuScene: SKScene {
    var state: AstralGameStateManager?
    var logo: SKSpriteNode!
    var newGameButtonNode: SKLabelNode!
    var continueButtonNode: SKLabelNode!
    var optionsButtonNode: SKLabelNode!
    var cursorNode: SKSpriteNode!
    var cursorFrames: [SKTexture] = []

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black

        // Add a background image
        /*
        let backgroundNode = SKSpriteNode(imageNamed: "backgroundImage")
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(backgroundNode)
         */
        
        // Add a game logo
        let logoNode = SKSpriteNode(imageNamed: "logo1")
        logoNode.position = CGPoint(x: size.width/2, y: size.height*0.75)
        logoNode.xScale = 3.0
        logoNode.yScale = 3.0
        logoNode.texture?.filteringMode = .nearest
        addChild(logoNode)

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
        /*
        cursorNode = SKSpriteNode(imageNamed: "cursor")
        cursorNode.position = newGameButtonNode.position
        addChild(cursorNode)
         */
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
        let cursorAnimatedAtlas = SKTextureAtlas(named: "Cursor")
        var frames: [SKTexture] = []
        
        let numImages = cursorAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let cursorTextureName = "cursor\(i)"
            frames.append(cursorAnimatedAtlas.textureNamed(cursorTextureName))
        }
        cursorFrames = frames
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            
            if nodes.contains(newGameButtonNode) {
                print("lmao new shit")
                // Transition to new game state
            } else if nodes.contains(continueButtonNode) {
                print("c0ntinue lol")
                // Transition to continue state
            } else if nodes.contains(optionsButtonNode) {
                // Transition to options state
                print("wow options")
            }
        }
    }
}

