//
//  AstralGameStateManager.swift
//  astral
//
//  Created by Joseph Haygood on 5/29/23.
//

import Foundation


class AstralGameStateManager {
    var gameState: AstralGameState = .mainMenu
    
    private(set) var currentState: AstralGameState? {
        didSet {
            // Add behavior when state changes if necessary
            switch currentState {
            case .mainMenu:
                
                break
            case .optionsMenu:
                // Your code when transitioning to optionsMenu
                break
            case .inGame:
                // Your code when transitioning to inGame
                break
            case .inGameCutscene:
                // Your code when transitioning to inGameCutscene
                break
            case .inGameVictory:
                // Your code when transitioning to inGameVictory
                break
            case .inGameDefeat:
                // Your code when transitioning to inGameDefeat
                break
            case .stageSelect:
                // Your code when transitioning to stageSelect
                break
            case .shop:
                // Your code when transitioning to shop
                break
            case .equipmentSelection:
                // Your code when transitioning to equipmentSelection
                break
            case .none:
                break
            }
        }
    }
    
    func enterState(_ state: AstralGameState) {
        self.gameState = state
    }
    
    // Additional methods related to managing game state can be added here
}
