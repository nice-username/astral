//
//  MainMenuScene.swift
//  astral
//
//  Created by Joseph Haygood on 6/18/23.
//

import Foundation
import AVFoundation
import UIKit
import SpriteKit




struct AstralMainMenuItem {
    let labelNode: SKLabelNode
    let action: (() -> Void)?
    var isLocked: Bool
    let lockedText: String?
    var index: Int?


    init(withText text: String, position: CGPoint, action: (() -> Void)?, isLocked: Bool, lockedText: String?, index: Int?) {
        let buttonNode = SKLabelNode(fontNamed: "VisitorTT1BRK")
        buttonNode.text = text
        buttonNode.fontSize = 40
        buttonNode.fontColor = SKColor.white
        buttonNode.position = position

        self.labelNode = buttonNode
        self.action = action
        self.isLocked = isLocked
        self.lockedText = lockedText
        self.index = index
    }
}





class AstralMainMenuScene: SKScene {
    var state: AstralGameStateManager?
    var audioPlayer: AVAudioPlayer?
    var logo: SKSpriteNode!
    var menuItems: [AstralMainMenuItem] = []
    var selectedItem: Int?
    var cursorNode: SKSpriteNode!
    var cursorFrames: [SKTexture] = []
    var backgrounds: [AstralMainMenuBackground] = []
    var currentBackgroundIndex = 0
    var currentBackground : SKSpriteNode!
    var nextBackground : SKSpriteNode!
    var isTransitioning = false



    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        self.loadAudioFiles()
        self.setupBackgrounds()
        
        // Add logo
        let logoNode = SKSpriteNode(imageNamed: "logo1")
        logoNode.position = CGPoint(x: size.width/2, y: size.height*0.75)
        logoNode.xScale = 3.0
        logoNode.yScale = 3.0
        logoNode.zPosition = 2
        logoNode.texture?.filteringMode = .nearest
        self.addChild(logoNode)
        
        AstralEffectsManager.shared.displaceSpriteAnimated(for: logoNode,
                                                           repeatRate: 0.005 ... 0.02,
                                                           widthRange:  0.05 ... 0.7,
                                                           heightRange: 0.05 ... 0.25)
        
        // Add menu buttons
        let newGameMenuItem = AstralMainMenuItem(withText: "New Game",
                                                 position: CGPoint(x: size.width / 2, y: size.height * 0.5),
                                                 action: { print("New Game Selected") },
                                                 isLocked: false,
                                                 lockedText: nil,
                                                 index: 0)
                                                 
        let continueMenuItem = AstralMainMenuItem(withText: "Continue",
                                                  position: CGPoint(x: size.width / 2, y: size.height * 0.45),
                                                  action: { print("Continue Selected") },
                                                  isLocked: false,
                                                  lockedText: nil,
                                                  index: 1)

        let optionsMenuItem = AstralMainMenuItem(withText: "Options",
                                                 position: CGPoint(x: size.width / 2, y: size.height * 0.35),
                                                 action: { print("Options Selected") },
                                                 isLocked: false,
                                                 lockedText: nil,
                                                 index: 3)
        
        let editorMenuItem  = AstralMainMenuItem(withText: "Editor",
                                                 position: CGPoint(x: size.width / 2, y: size.height * 0.40),
                                                 action: { print("Editor Selected") },
                                                 isLocked: false,
                                                 lockedText: nil,
                                                 index: 2)
                                                 
        menuItems = [newGameMenuItem, continueMenuItem, optionsMenuItem, editorMenuItem]
        menuItems.forEach { menuItem in
            addChild(menuItem.labelNode)
        }
        
        // Add menu selection cursor
        self.loadCursorAnimation()
        self.cursorNode = SKSpriteNode(texture: self.cursorFrames[0])
        cursorNode.position.x = menuItems[0].labelNode.position.x - 115
        cursorNode.position.y = menuItems[0].labelNode.position.y + (cursorNode.size.height / 2) + 3
        cursorNode.xScale = 2.0
        cursorNode.yScale = 2.0
        cursorNode.texture?.filteringMode = .nearest
        animateCursor()
        addChild(cursorNode)
        
        self.startBackgroundTransitions()
    }
    
    
    
    func loadAudioFiles() {
        if let url = Bundle.main.url(forResource: "menu_select", withExtension: "wav") {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.prepareToPlay()
            } catch {
                print("Could not load sound file.")
            }
        }
    }
    
    func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
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
    
    
    
    func setupBackgrounds() {
        let atlasNames = ["MainMenuBackground00", "MainMenuBackground01", "MainMenuBackground02", "MainMenuBackground03"]
        
        self.backgrounds = atlasNames.map { AstralMainMenuBackground(atlasNamed: $0, parent: self) }
        
        // Randomly select the initial background
        self.currentBackgroundIndex = Int.random(in: 0..<atlasNames.count)
        
        // Now, go through each background and add or remove their nodes from the scene as necessary
        for (index, background) in self.backgrounds.enumerated() {
            if index == self.currentBackgroundIndex {
                // This is the initial background, so its nodes should be added to the scene
                background.addNodesToParent()
            } else {
                // All other backgrounds' nodes should be removed from the scene
                background.removeNodesFromParent()
            }
        }
    }

    func switchBackgrounds(oldBg: AstralMainMenuBackground, newBg: AstralMainMenuBackground) {
        oldBg.nodes.forEach { node in
            node.isHidden = true
            node.removeFromParent()
        }

        for node in newBg.nodes {
            if node.parent == nil {
                self.addChild(node)
            }
        }

        newBg.nodes.forEach { $0.isHidden = false }
    }

    func transitionBackgrounds(oldBg: AstralMainMenuBackground, newBg: AstralMainMenuBackground,
                               flickerCountRange: ClosedRange<Int> = 3...7,
                               waitDurationRange: ClosedRange<TimeInterval> = 0.0625...0.25,
                               completion: @escaping () -> Void) {
        let totalFlickerCount = Int.random(in: flickerCountRange)
        
        // Set the isInTransition flag
        oldBg.isInTransition = true
        newBg.isInTransition = true

        // Add the new background's nodes to the scene if not already added.
        for node in newBg.nodes {
            if node.parent == nil {
                self.addChild(node)
            }
        }

        // Create an array of actions
        var actions: [SKAction] = []
        
        for i in 0..<totalFlickerCount {
            let waitDuration = Double.random(in: waitDurationRange)

            let flickerAction: SKAction
            if i % 2 == 0 {
                flickerAction = SKAction.run { [weak self] in
                    self?.switchBackgrounds(oldBg: oldBg, newBg: newBg)
                }
            } else {
                flickerAction = SKAction.run { [weak self] in
                    self?.switchBackgrounds(oldBg: newBg, newBg: oldBg)  // Switch old and new backgrounds
                }
            }
            let flickerSequence = SKAction.sequence([flickerAction, SKAction.wait(forDuration: waitDuration)])
            actions.append(flickerSequence)
        }
        
        // Add a completion action to the sequence
        let finalAction = SKAction.run {
            self.switchBackgrounds(oldBg: oldBg, newBg: newBg)
            oldBg.isInTransition = false
            newBg.isInTransition = false
            completion()
        }
        actions.append(finalAction)
        
        // Combine actions into a final sequence
        let finalAnim = SKAction.sequence(actions)
        
        // Run final animation on the new background's top node
        self.run(finalAnim)
    }



    
    
    
    func startBackgroundTransitions(after time: ClosedRange<Double> = 5.0...5.1) {
        let transitionDuration = Double.random(in: time)
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) { [weak self] in
            guard let self = self else { return }
            
            // Get the current background
            let oldBackground = self.backgrounds[self.currentBackgroundIndex]
            
            // Calculate the index of the new background
            let nextBackground = (self.currentBackgroundIndex + 1) % self.backgrounds.count
            let newBackground = self.backgrounds[nextBackground]
            
             // Perform the transition
            self.transitionBackgrounds(oldBg: oldBackground, newBg: newBackground) {
                self.currentBackgroundIndex = nextBackground
                
                // Start the next transition
                self.startBackgroundTransitions()
            }
        }
    }

    
    
    func menuItem(atPoint point: CGPoint) -> AstralMainMenuItem? {
        let nodes = self.nodes(at: point)
        return menuItems.first(where: { nodes.contains($0.labelNode) })
    }
    
    
    
    func resetBackgrounds(except currentIndex: Int) {
        print("Reset")
        for (index, background) in backgrounds.enumerated() {
            if index != currentIndex {
                background.resetBackground()
            }
        }
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
    	
    
    func moveCursor(to menuItem: AstralMainMenuItem) {
        let newPoint = CGPoint(x: menuItem.labelNode.position.x - 115,
                               y: menuItem.labelNode.position.y + (cursorNode.size.height / 2) - 3)
        let moveAction = SKAction.move(to: newPoint, duration: 0.2)
        let trailAction = createTrailAction(to: newPoint, duration: 0.2)
        cursorNode.run(SKAction.group([moveAction, trailAction]))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let menuItem = menuItem(atPoint: location) {
            self.audioPlayer?.play()
            self.vibrate(style: .medium)
            if self.selectedItem != menuItem.index {
                moveCursor(to: menuItem)
                self.selectedItem = menuItem.index
            }
            if let action = menuItem.action {
                action()
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        for background in self.backgrounds {
            if background.isInTransition || background === self.backgrounds[self.currentBackgroundIndex] {
                background.scroll()
                /*
                if let bottomNode = currentBackground.bottomNode {
                    if currentBackground.lastTextureShowing {
                        }
                    }
                }
                */
            }
        }
    }


    
}

