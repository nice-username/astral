//
//  AstralMainMenuBackground.swift
//  astral
//
//  Created by Joseph Haygood on 7/7/23.
//

import Foundation
import SpriteKit




///
/// The main menu backgrounds are split up into multiple textures because they are so large.
/// SpriteKit's SKTextureAtlas helps us load the needed texture on-demand.
/// An SKTexture's dimensions are limited to 4096x4096.
///
class AstralMainMenuBackground {
    public var nodes: [SKSpriteNode] = []
    private let atlas: SKTextureAtlas
    private var textureNames: [String]
    private var textureIndex = 0
    private var nextNodePositionY: CGFloat = 0.0
    private var parent: SKScene


    // We keep track of the bottom node to know when to add a new one at the top
    public var bottomNode: SKSpriteNode? {
        return nodes.first
    }
    // Similarly, we keep track of the top node to know when to remove it
    public var topNode: SKSpriteNode? {
        return nodes.last
    }


    init(atlasNamed: String, parent: SKScene) { // take a reference to the parent scene
        atlas = SKTextureAtlas(named: atlasNamed)
        self.textureNames = atlas.textureNames.sorted()
        self.parent = parent // assign the parent reference
        // Initialize the first three nodes
        for _ in 0..<3 {
            let node = addNewNodeAtTop()
            self.nodes.append(node)
            parent.addChild(node) // add to parent when initializing
        }
    }

    func shiftNodes() {
        // Remove the bottom node when it goes off-screen
        let removedNode = nodes.removeFirst()
        
        // Update the next node position
        nextNodePositionY -= removedNode.size.height
        
        // Remove the node from its parent
        removedNode.removeFromParent()
        
        // Re-use the removed node at the top
        let node = addNewNodeAtTop()
        removedNode.texture = node.texture // update the texture of the removed node
        removedNode.position = node.position // update the position of the removed node
        parent.addChild(removedNode) // add it back to the parent
        nodes.append(removedNode) // add it back to the nodes array
    }

    
    func scroll() {
        // Adjust as necessary
        let scrollSpeed: CGFloat = 1.0
        for node in nodes {
            node.position.y -= scrollSpeed
        }
        // If the bottom node is off-screen, shift nodes
        if let bottomNode = bottomNode, bottomNode.position.y + bottomNode.size.height < 0 {
            shiftNodes()
        }
    }

    private func addNewNodeAtTop() -> SKSpriteNode {
        let textureName = self.textureNames[textureIndex]
        let texture = atlas.textureNamed(textureName)
        let node = SKSpriteNode(texture: texture)
        node.xScale = 2.0
        node.yScale = 2.0
        node.alpha  = 0.75 
        node.texture?.filteringMode = .nearest
        node.position.x = node.frame.width / 2
        // position the new node above the top node
        node.position.y = nextNodePositionY - 1
        // update the next node's y-position
        nextNodePositionY += node.size.height
        node.zPosition = -1
        node.isHidden = false
        print("Adding \(textureName) to \(node.position)")
        // cycle through the sorted texture names
        self.textureIndex = (textureIndex + 1) % self.textureNames.count

        return node
    }
    
    func setNodesVisibility(visible: Bool) {
        for node in self.nodes {
            node.isHidden = !visible
        }
    }
    
    func addNodesToParent() {
        for node in nodes {
            if node.parent == nil {
                self.parent.addChild(node)
            }
        }
    }

    func removeNodesFromParent() {
        for node in nodes {
            node.removeFromParent()
        }
    }
}
