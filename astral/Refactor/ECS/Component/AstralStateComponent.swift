//
//  AstralStateComponent.swift
//  astral
//
//  Created by Joseph Haygood on 2/14/25.
//

import Foundation
import GameplayKit

class AstralStateComponent: GKComponent, Resettable {
    var isActive: Bool = false
    var isInvincible: Bool = false
    
    func reset() {
        isActive = false
        isInvincible = false
    }
}
