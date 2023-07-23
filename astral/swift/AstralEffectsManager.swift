//
//  AstralEffectsManager.swift
//  astral
//
//  Created by Joseph Haygood on 6/28/23.
//

import Foundation
import SpriteKit

class AstralEffectsManager {
    static let shared = AstralEffectsManager()

    private init() { }

    // Displacement of a given node with a random glitch effect
    func displaceSprite(for node: SKSpriteNode, cropRect: CGRect) {
        guard let nodeTexture = node.texture else { return }

        let croppedTexture = SKTexture(rect: cropRect, in: nodeTexture)
        let displacedNode = SKSpriteNode(texture: croppedTexture)
        
        displacedNode.alpha = CGFloat.random(in: 0.25...0.75)
        displacedNode.xScale = 3.0
        displacedNode.yScale = 3.0
        displacedNode.texture?.filteringMode = .nearest
        displacedNode.position.x = node.position.x + CGFloat.random(in: -100...100)
        displacedNode.position.y = node.position.y + CGFloat.random(in: -50...50)
        displacedNode.zPosition = node.zPosition - 1
        node.parent?.addChild(displacedNode)

        let wait = SKAction.wait(forDuration: 0.2 + CGFloat.random(in: 0...0.1))
        let fadeOut = SKAction.fadeOut(withDuration: 0.2 + CGFloat.random(in: 0...0.1))
        let removeAction = SKAction.removeFromParent()
        displacedNode.run(SKAction.sequence([wait, fadeOut, removeAction]))
    }
    
    
    
    
    // Displacement of a given node with a random glitch effect
    func displaceSpriteAnimated(for node: SKSpriteNode,
                                repeatRate: ClosedRange<Double>,
                                widthRange: ClosedRange<CGFloat>,
                                heightRange: ClosedRange<CGFloat>) {
        
        let randomWidth = CGFloat.random(in: widthRange)
        let randomHeight = CGFloat.random(in: heightRange)
        
        let rect = CGRect(x: CGFloat.random(in: 0.0...1),
                          y: CGFloat.random(in: 0.0...1),
                          width: randomWidth, //CGFloat.random(in: 0.4...1),
                          height: randomHeight) //CGFloat.random(in: 0.2...1))

        self.displaceSprite(for: node, cropRect: rect)
        
        let waitAction = SKAction.wait(forDuration: TimeInterval.random(in: repeatRate))
        let runBlockAction = SKAction.run { [weak self, weak node] in
            guard let self = self, let node = node else { return }
            self.displaceSpriteAnimated(for: node, repeatRate: repeatRate, widthRange: widthRange, heightRange: heightRange)
        }
        
        node.run(SKAction.sequence([waitAction, runBlockAction]))
    }


    
    // Other effects go here
}
