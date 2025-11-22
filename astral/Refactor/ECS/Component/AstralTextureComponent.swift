//
//  AstralTextureComponent.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/25.
//

import Foundation
import GameplayKit
import SpriteKit

// MARK: - Texture Management Component
class AstralTextureComponent: GKComponent {
    private static var globalTextureCache: [String: [SKTexture]] = [:]

    var textures: [SKTexture]

    init(imageNamed: String) {
        if let texture = AstralTextureComponent.cachedTexture(named: imageNamed) {
            self.textures = [texture]
        } else {
            let texture = SKTexture(imageNamed: imageNamed)
            AstralTextureComponent.cacheTexture(texture, named: imageNamed)
            self.textures = [texture]
        }
        super.init()
    }

    init(atlasNamed: String) {
        self.textures = AstralTextureComponent.loadTextures(fromAtlasName: atlasNamed)
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func loadTextures(fromAtlasName atlasName: String) -> [SKTexture] {
        if let cachedTextures = globalTextureCache[atlasName] {
            return cachedTextures
        }

        let atlas = SKTextureAtlas(named: atlasName)
        let textureNames = atlas.textureNames.sorted()
        let textures = textureNames.map { atlas.textureNamed($0) }

        textures.forEach { texture in
            texture.filteringMode = .nearest
        }

        globalTextureCache[atlasName] = textures
        return textures
    }

    static func preloadTextureAtlas(_ atlasName: String, completion: @escaping () -> Void) {
        let atlas = SKTextureAtlas(named: atlasName)
        atlas.preload {
            let _ = loadTextures(fromAtlasName: atlasName)
            completion()
        }
    }

    static func preloadTextureAtlases(_ atlasNames: [String], completion: @escaping () -> Void) {
        let group = DispatchGroup()

        atlasNames.forEach { atlasName in
            group.enter()
            preloadTextureAtlas(atlasName) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    static func preloadTexture(named name: String, completion: @escaping () -> Void) {
        let texture = SKTexture(imageNamed: name)
        texture.preload {
            cacheTexture(texture, named: name)
            completion()
        }
    }

    private static func cachedTexture(named name: String) -> SKTexture? {
        return globalTextureCache[name]?.first
    }

    private static func cacheTexture(_ texture: SKTexture, named name: String) {
        if globalTextureCache[name] == nil {
            globalTextureCache[name] = [texture]
        }
    }
    
    static func emptyCache() {
        globalTextureCache.removeAll()
    }

    static func textures(forAtlas name: String) -> [SKTexture]? {
        return globalTextureCache[name]
    }

    static func texture(named name: String) -> SKTexture? {
        return globalTextureCache[name]?.first
    }

    static func createAnimationAction(forAtlas atlasName: String, frameTime: TimeInterval, loop: Bool = true) -> SKAction? {
        guard let textures = textures(forAtlas: atlasName) else { return nil }
        let action = SKAction.animate(with: textures, timePerFrame: frameTime)
        return loop ? SKAction.repeatForever(action) : action
    }
}
