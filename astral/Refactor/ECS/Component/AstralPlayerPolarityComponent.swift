//
//  AstralPlayerPolarityComponent.swift
//  astral
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import GameplayKit

class AstralPolarityComponent: GKComponent {
    // Reference to the sprite node component
    private var spriteComponent: GKSKNodeComponent? {
        return entity?.component(ofType: GKSKNodeComponent.self)
    }
    
    // Cached animations for both states
    private var cachedAnimations: [AstralPolarityState: SKAction] = [:]
    private var currentPolarity: AstralPolarityState = .white
    
    // Overlay sprite for the animation
    private var overlaySprite: SKSpriteNode?
    
    // Animation configuration
    private let frameTime: TimeInterval = 1.0 / 60.0    // frame rate = 60
    private let cooldownDuration: TimeInterval = 0.75
    private var lastSwitchTime: TimeInterval = 0
    private var animationScale: CGFloat = 4.0
    
    var polarity: AstralPolarityState {
        return currentPolarity
    }
    
    override init() {
        super.init()
        setupAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didAddToEntity() {
        super.didAddToEntity()
        setupOverlaySprite()
    }
    
    private func setupOverlaySprite() {
        guard let mainSprite = spriteComponent?.node else { return }
        
        // Create overlay sprite (initially invisible)
        overlaySprite = SKSpriteNode(color: .clear, size: mainSprite.frame.size)
        overlaySprite?.setScale(animationScale)
        overlaySprite?.zPosition = mainSprite.zPosition + 1
        
        // Add overlay as child of main sprite to inherit position/rotation
        mainSprite.addChild(overlaySprite!)
    }
    
    private func setupAnimations() {
        // Load and cache animations for both states
        for state in [AstralPolarityState.white, AstralPolarityState.black] {
            if let textures = loadTexturesForState(state) {
                let animation = SKAction.animate(with: textures, timePerFrame: frameTime)
                cachedAnimations[state] = animation
            }
        }
    }
    
    private func loadTexturesForState(_ state: AstralPolarityState) -> [SKTexture]? {
        let atlas = SKTextureAtlas(named: state.atlasName)
        
        // Create array of frame names in correct sequence
        let frames = state.frameRange.map { frameNumber in
            let paddedNumber = String(format: "%05d", frameNumber)
            return "\(state.framePrefix)\(paddedNumber).png"
        }
        
        // Load textures in sequence
        let textures = frames.compactMap { frameName -> SKTexture? in
            if atlas.textureNames.contains(frameName) {
                let texture = atlas.textureNamed(frameName)
                texture.filteringMode = .nearest
                return texture
            }
            return nil
        }
        
        return textures.isEmpty ? nil : textures
    }
    
    func switchPolarity(completion: (() -> Void)? = nil) {
        guard let overlaySprite = overlaySprite else { return }
        
        let currentTime = CACurrentMediaTime()
        guard (currentTime - lastSwitchTime) >= cooldownDuration else { return }
        
        lastSwitchTime = currentTime
        currentPolarity.toggle()
        
        guard let animation = cachedAnimations[currentPolarity] else { return }
        
        // Stop any current switch animation
        overlaySprite.alpha = 1.0
        overlaySprite.removeAction(forKey: "polaritySwitch")
        
        let sequence = SKAction.sequence([
            animation,
            SKAction.run { [weak self] in
                overlaySprite.alpha = 0.0
                completion?()
                self?.onSwitchComplete()
            }
        ])
        
        overlaySprite.run(sequence, withKey: "polaritySwitch")
    }
    
    private func onSwitchComplete() {
        // Notify other components or update game state if needed
        print("Polarity switch completed to: \(currentPolarity)")
    }
    
    func canSwitch() -> Bool {
        let currentTime = CACurrentMediaTime()
        return (currentTime - lastSwitchTime) >= cooldownDuration
    }
    
    func remainingCooldown() -> TimeInterval {
        let currentTime = CACurrentMediaTime()
        let timeSinceLastSwitch = currentTime - lastSwitchTime
        return max(0, cooldownDuration - timeSinceLastSwitch)
    }
    
    static func preloadAssets(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for state in [AstralPolarityState.white, AstralPolarityState.black] {
            group.enter()
            let atlas = SKTextureAtlas(named: state.atlasName)
            atlas.preload {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}
