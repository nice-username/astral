//
//  AstralSpriteManager.swift
//  astral
//
//  Created by Joseph Haygood on 4/20/24.
//

import Foundation
import SpriteKit

/// `AstralSprite` extends `SKSpriteNode` to include additional functionality for handling animations and texture management.
class AstralSprite: SKSpriteNode {
    private var textureCache = [String: [SKTexture]]()

    /// Initializes a sprite with a single static image.
    convenience init(imageNamed: String) {
        self.init(texture: SKTexture(imageNamed: imageNamed))
    }

    /// Initializes a sprite with an animation from a texture atlas.
    convenience init(animatedAtlasName: String, timePerFrame: TimeInterval, loop: Bool = true, loopCount: Int = 0) {
        let textures = AstralSprite.loadTextures(fromAtlasName: animatedAtlasName)
        self.init(texture: textures.first) // Set the first texture to initialize the sprite
        let animation = AstralSprite.createAnimationAction(with: textures, timePerFrame: timePerFrame, loop: loop, loopCount: loopCount)
        self.run(animation)
    }

    /// Static method to load textures from an atlas, ensuring they are only loaded once.
    private static func loadTextures(fromAtlasName atlasName: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: atlasName)
        let textureNames = atlas.textureNames.sorted()
        return textureNames.map { atlas.textureNamed($0) }
    }

    /// Static method to create an animation action from textures.
    private static func createAnimationAction(with textures: [SKTexture], timePerFrame: TimeInterval, loop: Bool = true, loopCount: Int = 0) -> SKAction {
        let animation = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        if loop {
            return SKAction.repeatForever(animation)
        } else if loopCount > 0 {
            return SKAction.repeat(animation, count: loopCount)
        } else {
            return animation
        }
    }
}


