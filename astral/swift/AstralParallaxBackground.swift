//
//  AstralBackground.swift
//  astral
//
//  Created by Joseph Haygood on 5/1/23.
//import Foundation
import SpriteKit

class AstralParallaxBackground: SKNode {    
    private let size: CGSize
    private var layers: [AstralParallaxBackgroundLayer]
    
    init(size: CGSize, layerSpeeds: [CGFloat] = [2.0, 6.0, 10.0, 16.0]) {
        self.size = size
        self.layers = []
        super.init()
        
        for index in 0..<layerSpeeds.count {
            let layerName = "stars_layer\(String(format: "%02d", index))"
            if let texture = loadTexture(named: layerName) {
                let layer = AstralParallaxBackgroundLayer(texture: texture, scrollingSpeed: layerSpeeds[index], isVisible: true)
                layer.zPosition = CGFloat(-index)
                layer.alpha = 0.05 + ((CGFloat(index) + 1.0) * 0.25)
                layer.texture?.filteringMode = .nearest
                addChild(layer)
                layers.append(layer)
            } else {
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ delta: TimeInterval, joystickDirection: AstralDirection) {
        let speedFactor: CGFloat = {
            switch joystickDirection {
                case .up:
                    return 0.5
                case .upRight, .upLeft:
                    return 0.75
                case .down:
                    return 1.5
                case .none, .right, .left, .downRight, .downLeft:
                    return 1.0
            }
        }()
        
        for (index, node) in children.enumerated() {
            if let background = node as? SKSpriteNode, layers[index].isVisible {
                let speed = layers[index].scrollingSpeed * speedFactor
                background.position.y += speed * CGFloat(delta)
                if background.position.y > size.height / 2 {
                    background.position.y -= size.height
                    // print("Layer \(index) looped, position reset to \(background.position.y)")
                }
            }
        }
    }
    
    func updateLayerVisibility(layerIndex: Int, isVisible: Bool) {
        if layerIndex >= 0 && layerIndex < layers.count {
            layers[layerIndex].isVisible = isVisible
            if let background = childNode(withName: "background\(layerIndex)") as? SKSpriteNode {
                background.isHidden = !isVisible
            }
        }
    }
    
    private func loadTexture(named textureName: String) -> SKTexture? {
        let textureAtlas = SKTextureAtlas(named: "BackgroundStars")
        return textureAtlas.textureNamed(textureName)
    }
}
