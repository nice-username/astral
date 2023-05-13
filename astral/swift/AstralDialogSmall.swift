//
//  AstralDialogSmall.swift
//  astral
//
//  Created by Joseph Haygood on 5/12/23.
//

import Foundation
import SpriteKit

import SpriteKit

class AstralDialogSmall: SKNode {
    var leftSprite: SKSpriteNode!
    var middleSprite: SKSpriteNode!
    var rightSprite: SKSpriteNode!
    var dialogLabel: SKLabelNode!

    init(dialogText: String, dialogWidth: CGFloat) {
        super.init()
        
        let middleWidth = dialogWidth - 6 // Subtract the width of the left and right sprites (3px + 3px)

        // Create the left, middle, and right sprites
        leftSprite = SKSpriteNode(imageNamed: "dialog3left.png")
        middleSprite = SKSpriteNode(imageNamed: "dialog3fill.png")
        middleSprite.size = CGSize(width: middleWidth, height: 13)
        rightSprite = SKSpriteNode(imageNamed: "dialog3right.png")

        // Position the sprites
        leftSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        middleSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        rightSprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        middleSprite.position = CGPoint(x: leftSprite.size.width, y: 0)
        rightSprite.position = CGPoint(x: leftSprite.size.width + middleWidth, y: 0)

        // Create the label node
        dialogLabel = SKLabelNode(text: dialogText)
        dialogLabel.position = CGPoint(x: leftSprite.size.width * 2, y: 1)
        dialogLabel.horizontalAlignmentMode = .left
        dialogLabel.verticalAlignmentMode = .center
        dialogLabel.fontName  = "VisitorTT1BRK"
        dialogLabel.fontSize  = 28
        dialogLabel.zPosition = 2.0
        dialogLabel.xScale    = 0.3333
        dialogLabel.yScale    = 0.3333
        
        // Set nearest neighbor filtering
        leftSprite.texture?.filteringMode = .nearest
        middleSprite.texture?.filteringMode = .nearest
        rightSprite.texture?.filteringMode = .nearest
        
        // Add the sprites and label to self
        self.xScale = 3.0
        self.yScale = 3.0
        self.addChild(leftSprite)
        self.addChild(middleSprite)
        self.addChild(rightSprite)
        self.addChild(dialogLabel)
    }
    
    func extendWidthTo(targetWidth: CGFloat, overTime duration: TimeInterval) {
        // Compute the width for the center sprite
        let centerWidth = targetWidth - leftSprite.size.width - rightSprite.size.width
        
        // Create actions
        let extendCenterAction = SKAction.resize(toWidth: centerWidth, duration: duration)
        let extendRightAction = SKAction.moveBy(x: centerWidth - middleSprite.size.width, y: 0, duration: duration)
        
        // Run actions
        self.middleSprite.run(extendCenterAction)
        self.rightSprite.run(extendRightAction)
        
        // Update the background size
        // self.size.width = targetWidth
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

