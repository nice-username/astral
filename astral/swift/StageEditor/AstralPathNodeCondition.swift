//
//  AstralPathNodeCondition.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation

protocol NodeCondition {
    func shouldTrigger(gameState: AstralGameState) -> Bool
}

//
// Default is always true
//
class DefaultCondition: NodeCondition {
    func shouldTrigger(gameState: AstralGameState) -> Bool {
        return true
    }
}
