//
//  PolarityTestScene.swift
//  astral
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import SpriteKit
import GameplayKit

class PolarityTestScene: SKScene {
    private var entities = Set<GKEntity>()
    private var testEntity: GKEntity?
    private var audioManager: AstralAudioManager?
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        backgroundColor = .darkGray
        
        audioManager = AstralAudioManager.shared
        
        // Preload assets
        AstralPolarityComponent.preloadAssets {
            print("Polarity assets preloaded")
            self.setupTestEntity()
        }
    }
    
    private func setupTestEntity() {
        let entity = GKEntity()
        
        // Create sprite node with the first frame from white atlas
        let atlas = SKTextureAtlas(named: "polarity_switch_white")
        let firstFrame = SKTexture(imageNamed: "polarity_blue_background")
        firstFrame.filteringMode = .nearest
        
        let spriteNode = SKSpriteNode(texture: firstFrame)
        spriteNode.position = CGPoint(x: frame.midX, y: frame.midY)
        spriteNode.setScale(0.25) // Adjust scale as needed
        
        // Add components
        let spriteComponent = GKSKNodeComponent(node: spriteNode)
        let polarityComponent = AstralPolarityComponent()
        if let audioManager = audioManager {
            let sfxComponent = AstralSoundEffectComponent(audioManager: audioManager)
            sfxComponent.registerSound("switch", filename: "def_win_31.wav")
            entity.addComponent(sfxComponent)
        }
        
        entity.addComponent(spriteComponent)
        entity.addComponent(polarityComponent)
        
        // Add sprite to scene and entity to our set
        addChild(spriteNode)
        entities.insert(entity)
        testEntity = entity
        
        // Add instructions
        let instructions = SKLabelNode(text: "Tap anywhere to switch polarity")
        instructions.fontSize = 20
        instructions.fontName = "Helvetica"
        instructions.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(instructions)
        
        // Add state label
        let stateLabel = SKLabelNode(text: "Current: White")
        stateLabel.fontSize = 16
        stateLabel.fontName = "Helvetica"
        stateLabel.position = CGPoint(x: frame.midX, y: frame.minY + 50)
        stateLabel.name = "stateLabel"
        addChild(stateLabel)
        
        // Debug: print available texture names
        print("Available textures in white atlas: \(atlas.textureNames)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let entity = testEntity,
              let polarityComponent = entity.component(ofType: AstralPolarityComponent.self) else { return }
        
        if polarityComponent.canSwitch() {
            entity.node?.position = touches.first!.location(in: self)
            entity.switchPolarity()
            entity.component(ofType: AstralSoundEffectComponent.self)?.playSound("switch")
            
            // Update state label
            if let label = childNode(withName: "stateLabel") as? SKLabelNode {
                label.text = "Current: \(polarityComponent.polarity == .white ? "White" : "Black")"
            }
        } else {
            // Optional: Show cooldown feedback
            if let label = childNode(withName: "stateLabel") as? SKLabelNode {
                let cooldown = String(format: "%.1f", polarityComponent.remainingCooldown())
                label.text = "Cooldown: \(cooldown)s"
            }
        }
    }
}

// MARK: - Scene Setup
extension PolarityTestScene {
    static func createScene() -> PolarityTestScene {
        let scene = PolarityTestScene()
        scene.scaleMode = .resizeFill
        return scene
    }
}
