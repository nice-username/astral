//
//  AstralParallaxBackgroundLayer2.swift
//  astral
//
//  Created by Joseph Haygood on 8/24/23.
//

import Foundation
import SpriteKit



class AstralParallaxBackgroundLayer2: SKNode {
    private var atlas: SKTextureAtlas
    private var layers: [SKSpriteNode] = []
    private var opacity: CGFloat
    private var scrollingSpeed: CGFloat
    private var scrollingDirection: CGVector
    private var shouldLoop: Bool
    private var textureIndex = 2
    private var nextNodePositionY: CGFloat = 0.0


    init(atlasNamed: String, direction: CGVector, speed: CGFloat = 1.0, opacity: CGFloat = 1, shouldLoop: Bool = false) {
        self.atlas = SKTextureAtlas(named: atlasNamed)
        self.scrollingSpeed = speed
        self.scrollingDirection = direction
        self.shouldLoop = shouldLoop
        self.opacity = opacity
        super.init()
        
        // Initialize the first three textures
        let textureNames = atlas.textureNames.sorted()
        for i in 0..<min(textureNames.count, 3) {
            let textureName = textureNames[i]
            addNewLayer(textureName: textureName)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getWidth() -> CGFloat {
        if !self.layers.isEmpty {
            return self.layers[0].frame.width
        } else {
            print("Can't get the width of the background layer because you haven't loaded it yet.")
            return 0
        }
    }
    
    public func getHeight() -> CGFloat {
        if !self.layers.isEmpty {
            return self.layers[0].frame.height
        } else {
            print("Can't get the height of the background layer because you haven't loaded it yet.")
            return 0
        }
    }
    
    private func addNewLayer(textureName: String) {
        let texture = self.atlas.textureNamed(textureName)
        
        let node = SKSpriteNode(texture: texture)
        node.xScale = 2.0
        node.yScale = 2.0
        node.texture?.filteringMode = .nearest
        node.zPosition = -1
        
        node.position.y = self.nextNodePositionY
        self.nextNodePositionY += node.size.height
        
        print("Adding texture at y: \(node.position.y), size: \(node.size.height * node.yScale)")
        
        self.addChild(node)
        self.layers.append(node)
    }
    
    
    func update(deltaTime: TimeInterval) {
        let scrollAmount = scrollingDirection.dy * scrollingSpeed

        for layer in layers {
            layer.position.y -= scrollAmount
        }

        // Check if the bottom layer has scrolled off the screen
        if let bottomLayer = layers.first, bottomLayer.position.y + bottomLayer.size.height < 0 {
            if shouldLoop {
                // Move the bottom layer to the top
                bottomLayer.position.y = layers.last!.position.y + layers.last!.size.height
                // Optionally update the texture to the next one in the sequence
                updateTextureForLoopingLayer(layer: bottomLayer)
                // Move the bottom layer to the last position in the array
                layers.append(layers.removeFirst())
            }
        }
    }


    private func updateTextureForLoopingLayer(layer: SKSpriteNode) {
        // If you want to cycle through different textures, you can update the layer's texture here
        // Increment textureIndex and wrap it around if it goes past the number of textures in the atlas
        textureIndex = (textureIndex + 1) % atlas.textureNames.count
        let textureName = atlas.textureNames.sorted()[textureIndex]
        layer.texture = atlas.textureNamed(textureName)
    }


}



