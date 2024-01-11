//
//  AstralStageEditorPopupMenu.swift
//  astral
//
//  Created by Joseph Haygood on 1/5/24.
//

import Foundation
import SpriteKit

class AstralStageEditorPopupMenu: SKNode {
    public var menuOptions: [SKLabelNode] = []
    public let background: SKShapeNode
    public let titleLabel: SKLabelNode
    private let titleLine: SKShapeNode
    public var subMenu: AstralStageEditorPopupMenu?
    public var isOpen: Bool = false

    
    init(size: CGSize, title: String = "") {
        
        // Create the rounded rectangle background
        background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = SKColor.black.withAlphaComponent(0.925)
        background.lineWidth = 0.0
        background.zPosition = 7
        
        // Title label setup
        titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "AvenirNext-Regular"
        titleLabel.fontSize = 24
        titleLabel.fontColor = SKColor.white
        titleLabel.zPosition = 8
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 30)
        
        titleLine = SKShapeNode(rect: CGRect(x: 0, y: 0, width: background.frame.width, height: 1))
        titleLine.strokeColor = .white
        titleLine.fillColor = .white
        titleLine.zPosition = 8
        titleLine.alpha = 0.75
        super.init()
        
        self.zPosition = 6
        
        // Add nodes to the menu
        self.addChild(background)
        self.addChild(titleLabel)
        self.addChild(titleLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addMenuOption(text: String, fontSize: CGFloat) {
        let optionLabel = SKLabelNode(text: text)
        optionLabel.fontName = "AvenirNext-Regular"
        optionLabel.fontSize = fontSize
        optionLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        optionLabel.zPosition = 9
        optionLabel.horizontalAlignmentMode = .left
        optionLabel.verticalAlignmentMode = .center
        optionLabel.isUserInteractionEnabled = false
        
        // Create a background node (button) slightly larger than the label
        let backgroundSize = CGSize(width: background.frame.width, height: optionLabel.frame.height + 32)
        let backgroundNode = SKShapeNode(rectOf: backgroundSize, cornerRadius: 0)
        backgroundNode.fillColor = SKColor.clear
        backgroundNode.strokeColor = SKColor.clear
        backgroundNode.name = text.lowercased() + "Button"
        backgroundNode.zPosition = 8
        backgroundNode.position.x += background.frame.width / 2.0 - 20

        // Add background to label node
        optionLabel.addChild(backgroundNode)
                
        // Add background node to the menu
        self.addChild(optionLabel)
        menuOptions.append(optionLabel)
    }
    
    func show(in scene: SKScene, position: CGPoint) {
        isOpen = true
        self.position = position
        self.setScale(0.125)
        self.removeFromParent()
        scene.addChild(self)
        let scaleIn = SKAction.scale(to: 1.1, duration: 0.125)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1667)
        self.run(SKAction.sequence([scaleIn, scaleDown]), withKey: "visibility")
    }
    
    func hide() {
        isOpen = false
        let scaleOut = SKAction.scale(to: 0, duration: 0.125)
        let remove = SKAction.removeFromParent()
        self.run(SKAction.sequence([scaleOut, remove]), withKey: "visibility")
        if let menu = subMenu {
            menu.hide()
        }
    }
    
    public func layoutMenuOptions() {
        let leftPadding: CGFloat = 20
        let topPadding: CGFloat = 30
        let spacingBetweenTitleAndFirstOption: CGFloat = 64
        let spacingBetweenOptions: CGFloat = 32
        
        // Calculate the total height of the menu
        let totalHeightOfOptions = CGFloat(menuOptions.count) * spacingBetweenOptions + CGFloat(menuOptions.count - 1) * 32 // Assuming each label's height is roughly 32 points
        let totalContentHeight = topPadding + titleLabel.frame.size.height + spacingBetweenTitleAndFirstOption + totalHeightOfOptions
        
        // Resize the background to fit all content
        let newSize = CGSize(width: background.frame.width, height: totalContentHeight)
        background.path = CGPath(roundedRect: CGRect(x: -newSize.width / 2, y: -newSize.height / 2, width: newSize.width, height: newSize.height), cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        // Reposition the titleLabel
        titleLabel.position = CGPoint(x: -newSize.width / 2 + leftPadding, y: newSize.height / 2 - topPadding)
        titleLine.position = CGPoint(x: background.frame.minX, y: titleLabel.frame.maxY - (titleLabel.frame.height * 2))
        
        // Reposition each menu option label
        var currentYPosition = titleLabel.position.y - titleLabel.frame.size.height / 2 - spacingBetweenTitleAndFirstOption
        for option in menuOptions {
            option.position = CGPoint(x: titleLabel.position.x, y: currentYPosition)
            currentYPosition -= spacingBetweenOptions + option.frame.size.height
        }
    }
    
    
    func addBoundingBox(to label: SKLabelNode) {
        // Calculate the size of the label's frame
        let labelSize = label.frame.size

        // Create a rectangle path slightly larger than the label's frame
        let padding: CGFloat = 10
        let rect = CGRect(x: 0 - padding / 2,
                          y: -labelSize.height / 2 - padding / 2,
                          width: labelSize.width + padding,
                          height: labelSize.height + padding)
        let shape = SKShapeNode(rect: rect, cornerRadius: 5)

        // Configure the shape's appearance
        shape.strokeColor = SKColor.orange // Choose the color for the box
        shape.lineWidth = 2 // Set the thickness of the box line
        shape.fillColor = SKColor.clear // Make the inside of the box transparent

        // Add the shape as a child of the label to move with it
        label.addChild(shape)
    }
    
    func openSubMenu(_ subMenu: AstralStageEditorPopupMenu) {
        // Hide the current menu or move it to the side
        self.hide()
        self.subMenu = subMenu

        // Add the sub-menu to the same scene
        if let scene = self.scene {
            subMenu.show(in: scene, position: self.position)
        }
    }
}
