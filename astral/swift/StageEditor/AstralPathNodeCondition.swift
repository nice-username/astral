//
//  AstralPathNodeCondition.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation

protocol AstralPathNodeCondition {
    func shouldTrigger(gameState: AstralGameState) -> Bool
}

//
// Default is always true
//
class DefaultCondition: AstralPathNodeCondition {
    func shouldTrigger(gameState: AstralGameState) -> Bool {
        return true
    }
}
