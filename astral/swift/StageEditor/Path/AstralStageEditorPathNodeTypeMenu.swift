//
//  AstralStageEditorPathNodeTypeMenu.swift
//  astral
//
//  Created by Joseph Haygood on 1/2/24.
//

import Foundation
import SpriteKit

class AstralStageEditorPathNodeTypeMenu: SKNode {
    private let background: SKShapeNode
    private let titleLabel: SKLabelNode
    public var menuOptions: [SKLabelNode] = []
    
    init(size: CGSize) {
        // Create the rounded rectangle background
        background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = SKColor.black.withAlphaComponent(0.925)
        background.lineWidth = 0.0
        background.zPosition = 7
        background.name = "nodeTypeMenuBackground"
        
        // Title label setup
        titleLabel = SKLabelNode(text: "Add node")
        titleLabel.fontName = "AvenirNext-Regular"
        titleLabel.fontSize = 24
        titleLabel.fontColor = SKColor.white
        titleLabel.zPosition = 8
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 30)
        
        super.init()
        
        // Add nodes to the menu
        self.addChild(background)
        self.addChild(titleLabel)
        
        let underline = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 2))
        underline.fillColor = SKColor.white
        underline.position = CGPoint(x: self.frame.minX, y: titleLabel.position.y + titleLabel.frame.size.height / 2 - (1/2))
        underline.zPosition = 8
        self.addChild(underline)
        
        // Add options to the menu
        addMenuOption(text: "Creation", fontSize: 32)
        addMenuOption(text: "Action", fontSize: 32)
        addMenuOption(text: "Pathing", fontSize: 32)
        menuOptions[0].name = "nodeTypeCreationOption"
        menuOptions[1].name = "nodeTypeActionOption"
        menuOptions[2].name = "nodeTypePathingOption"
        
        layoutMenuOptions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMenuOption(text: String, fontSize: CGFloat) {
        let optionLabel = SKLabelNode(text: text)
        optionLabel.fontName = "AvenirNext-Regular"
        optionLabel.fontSize = fontSize
        optionLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        optionLabel.zPosition = 8
        optionLabel.horizontalAlignmentMode = .left
        optionLabel.verticalAlignmentMode = .center
        self.addChild(optionLabel)
        menuOptions.append(optionLabel)
    }
    
    func show(in scene: SKScene, position: CGPoint) {
        self.position = position
        self.setScale(0.125) // Start scaled down to animate in
        
        scene.addChild(self)
        
        let scaleIn = SKAction.scale(to: 1.1, duration: 0.125)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1667)
        self.run(SKAction.sequence([scaleIn, scaleDown]))
    }
    
    func hide() {
        let scaleOut = SKAction.scale(to: 0, duration: 0.125)
        let remove = SKAction.removeFromParent()
        self.run(SKAction.sequence([scaleOut, remove]))
    }
    
    private func layoutMenuOptions() {
        let leftPadding: CGFloat = 20
        let topPadding: CGFloat = 30
        let spacingBetweenTitleAndFirstOption: CGFloat = 50
        let spacingBetweenOptions: CGFloat = 30
        
        // Calculate the total height of the menu
        let totalHeightOfOptions = CGFloat(menuOptions.count) * spacingBetweenOptions + CGFloat(menuOptions.count - 1) * 32 // Assuming each label's height is roughly 32 points
        let totalContentHeight = topPadding + titleLabel.frame.size.height + spacingBetweenTitleAndFirstOption + totalHeightOfOptions
        
        // Resize the background to fit all content
        let newSize = CGSize(width: background.frame.width, height: totalContentHeight)
        background.path = CGPath(roundedRect: CGRect(x: -newSize.width / 2, y: -newSize.height / 2, width: newSize.width, height: newSize.height), cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        // Reposition the titleLabel
        titleLabel.position = CGPoint(x: -newSize.width / 2 + leftPadding, y: newSize.height / 2 - topPadding)
        
        // Reposition each menu option label
        var currentYPosition = titleLabel.position.y - titleLabel.frame.size.height / 2 - spacingBetweenTitleAndFirstOption
        for option in menuOptions {
            option.position = CGPoint(x: titleLabel.position.x, y: currentYPosition)
            currentYPosition -= spacingBetweenOptions + option.frame.size.height
        }
    }
}
