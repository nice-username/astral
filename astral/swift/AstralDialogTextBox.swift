//
//  AstralDialogTextBox.swift
//  astral
//
//  Created by Joseph Haygood on 5/14/23.
//

import Foundation
import SpriteKit


class AstralDialogTextBox: SKNode {
    var scale: CGFloat
    var backgroundSprite: SKSpriteNode
    var textLabel: SKLabelNode
    var nextArrow: SKSpriteNode
    var textPages: [String]
    var textPageCurrentIndex: Int
    var charDisplayDuration: TimeInterval

    init(scale: CGFloat,
         backgroundSpriteName: String,
         textPages: [String],
         font: String,
         charDisplayDuration: TimeInterval,
         arrowSpriteName: String) {

        self.scale = scale
        self.backgroundSprite = SKSpriteNode(imageNamed: backgroundSpriteName)
        self.textLabel = SKLabelNode(fontNamed: font)
        self.nextArrow = SKSpriteNode(imageNamed: arrowSpriteName)
        self.textPages = textPages
        self.textPageCurrentIndex = 0
        self.charDisplayDuration = charDisplayDuration

        super.init()

        self.setupTextLabel()
        self.setupNextArrow()
        self.setupBackgroundSprite()
        self.displayCurrentPage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBackgroundSprite() {
        self.backgroundSprite.yScale = self.scale
        self.backgroundSprite.xScale = self.scale
        self.backgroundSprite.texture?.filteringMode = .nearest
        self.backgroundSprite.zPosition = 1
        self.addChild(self.backgroundSprite)
    }

    private func setupTextLabel() {
        self.textLabel.fontSize = 16
        self.textLabel.fontColor = SKColor.white
        self.textLabel.position = CGPoint(x: -self.backgroundSprite.size.width / 2 + 10,
                                          y: self.backgroundSprite.size.height / 2 - 8)
        self.textLabel.horizontalAlignmentMode = .left
        self.textLabel.verticalAlignmentMode = .top
        self.textLabel.numberOfLines = 2
        self.textLabel.preferredMaxLayoutWidth = self.backgroundSprite.size.width - 20
        self.textLabel.zPosition = 2
        
        // self.addShadow(to: self.textLabel, offset: CGPoint(x: 2, y: -2), color: SKColor.black)
        self.backgroundSprite.addChild(self.textLabel)
    }

    private func setupNextArrow() {
        self.nextArrow.position = CGPoint(x: self.backgroundSprite.size.width + 76,
                                          y: -self.backgroundSprite.size.height - 12)
        self.nextArrow.zPosition = 3
        self.nextArrow.xScale = self.scale - 2
        self.nextArrow.yScale = self.scale - 2
        self.nextArrow.texture?.filteringMode = .nearest
        self.addChild(self.nextArrow)
        self.animateNextArrow()
    }
    
    private func addShadow(to label: SKLabelNode, offset: CGPoint, color: SKColor) {
        let shadow = SKLabelNode(fontNamed: label.fontName)
        shadow.text = label.text
        shadow.fontColor = color
        shadow.position = CGPoint(x: label.position.x + offset.x, y: label.position.y - offset.y)
        shadow.zPosition = label.zPosition - 1
        label.parent?.addChild(shadow)
    }


    private func animateNextArrow() {
        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        let moveDown = moveUp.reversed()
        let sequence = SKAction.sequence([moveUp, moveDown])
        self.nextArrow.run(SKAction.repeatForever(sequence))
    }

    private func displayCurrentPage() {
        self.textLabel.text = ""
        let textToDisplay = self.textPages[self.textPageCurrentIndex]
        self.typeOutText(text: textToDisplay)
    }
    
    
    private func typeOutText(text: String) {
        var displayText = ""
        for (index, char) in text.enumerated() {
            let waitAction = SKAction.wait(forDuration: charDisplayDuration * Double(index))
            let typeAction = SKAction.run {
                displayText.append(char)
                self.textLabel.text = displayText
            }
            let sequenceAction = SKAction.sequence([waitAction, typeAction])
            self.textLabel.run(sequenceAction)
        }
    }


    func goToNextPage() {
        guard textPageCurrentIndex + 1 < textPages.count else { return }
        textPageCurrentIndex += 1
        self.displayCurrentPage()
    }

    func goToPreviousPage() {
        guard textPageCurrentIndex - 1 >= 0 else { return }
        textPageCurrentIndex -= 1
        self.displayCurrentPage()
    }
}
