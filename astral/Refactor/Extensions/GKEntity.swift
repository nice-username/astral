//
//  GKEntity.swift
//  astral
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import GameplayKit
import SpriteKit

extension GKEntity {
    var node: SKNode? {
        return component(ofType: GKSKNodeComponent.self)?.node
    }
    
    func switchPolarity() {
        guard let polarityComponent = component(ofType: AstralPlayerPolarityComponent.self),
              polarityComponent.canSwitch() else { return }
        
        polarityComponent.switchPolarity()
    }
    
    func getCurrentPolarity() -> AstralPolarityState? {
        return component(ofType: AstralPlayerPolarityComponent.self)?.polarity
    }
}
