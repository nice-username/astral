//
//  AstralBackgroundLayer.swift
//  astral
//
//  Created by Joseph Haygood on 5/1/23.
//

import Foundation
import SpriteKit

class AstralParallaxBackgroundLayer: SKSpriteNode {
    var scrollingSpeed: CGFloat
    var isVisible: Bool

    init(texture: SKTexture, scrollingSpeed: CGFloat, isVisible: Bool) {
        self.scrollingSpeed = scrollingSpeed
        self.isVisible = isVisible
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
