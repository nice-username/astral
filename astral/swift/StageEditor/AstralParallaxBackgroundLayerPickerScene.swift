//
//  AstralParallaxBackgroundLayerPickerScene.swift
//  astral
//
//  Created by Joseph Haygood on 8/24/23.
//

import Foundation
import SpriteKit

class AstralParallaxBackgroundLayerPickerScene: SKScene {
    public  var parallaxBackgrounds: [AstralParallaxBackgroundLayer2] = []
    private var lastUpdateTime: TimeInterval = 0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
          lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        if parallaxBackgrounds.indices.contains(1) {
            // parallaxBackgrounds[1].update(deltaTime: deltaTime)
            // print("hello?")
        }
        
        if deltaTime < 1.0 {
            for bg in self.parallaxBackgrounds {
                bg.update(deltaTime: deltaTime, gestureYChange: 0)
            }
        }
        
        lastUpdateTime = currentTime
    }
}
