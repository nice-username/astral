//
//  AstralParallaxBackgroundLayerPickerScene.swift
//  astral
//
//  Created by Joseph Haygood on 8/24/23.
//

import Foundation
import SpriteKit

class AstralParallaxBackgroundLayerPickerScene: SKScene {
    var parallaxBackground: AstralParallaxBackgroundLayer2!
    private var lastUpdateTime: TimeInterval = 0
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime
        parallaxBackground.update(deltaTime: deltaTime)
        lastUpdateTime = currentTime
    }
}
