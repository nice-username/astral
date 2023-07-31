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
    public var lastTextureShowing : Bool = false
    public var nodes: [SKSpriteNode] = []
    public let atlas: SKTextureAtlas
    public var isInTransition: Bool = false
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
        self.resetBackground(calledFromInit: true)
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
        let scrollSpeed: CGFloat = 2.0
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
        
        // cycle through the sorted texture names
        self.textureIndex = (textureIndex + 1) % self.textureNames.count
        self.lastTextureShowing = (textureIndex == self.textureNames.count - 1)

        return node
    }
    
    
    func resetBackground(calledFromInit: Bool = false) {        
        // Reset the variables
        self.textureIndex = 0
        self.nextNodePositionY = 0.0
        self.lastTextureShowing = false

        // If not called from the initializer, remove old nodes
        if !calledFromInit {
            for node in self.nodes {
                node.removeFromParent()
            }
            self.nodes.removeAll()
        }

        // Add the initial nodes back
        for _ in 0..<3 {
            let node = addNewNodeAtTop()
            if node.parent == nil {
                self.nodes.append(node)
                parent.addChild(node)
            }
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
