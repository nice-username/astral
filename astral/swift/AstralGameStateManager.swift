//
//  AstralGameStateManager.swift
//  astral
//
//  Created by Joseph Haygood on 5/29/23.
//

import Foundation
import SpriteKit

class AstralGameStateManager {
    // Reference to the main UIViewController
    var viewController: UIViewController?
    
    var gameViewController: SKView? {
        didSet {
            print("gameViewController set: \(gameViewController != nil)")
        }
    }
    
    static let shared = AstralGameStateManager()

    // Prevent direct initialization
    public init() {}
    
    private(set) var currentState: AstralGameState? {
        didSet {
            // Perform the transition when state changes
            switch currentState {
            case .mainMenu:
                // transition(to: MenuScene.self)
                break
            case .optionsMenu:
                // transition to the corresponding scene
                break
            case .inGame:
                // transition(to: AstralStage.self)
                break
            case .inGameCutscene:
                // transition to the corresponding scene
                break
            case .inGameVictory:
                // transition to the corresponding scene
                break
            case .inGameDefeat:
                // transition to the corresponding scene
                break
            case .stageSelect:
                // transition to the corresponding scene
                break
            case .shop:
                // transition to the corresponding scene
                break
            case .equipmentSelection:
                // transition to the corresponding scene
                break
            case .editor:
                transition(to: AstralStageEditor.self)
                break
            case .editorParallaxBackgroundPicker:
                transitionToViewController(AstralParallaxBackgroundLayerPicker())
                break
            case .none:
                break
            }
        }
    }
    
    func transitionTo(_ state: AstralGameState) {
        self.currentState = state
    }
    
    private func transitionToViewController(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let presentingViewController = viewController {
            presentingViewController.present(viewControllerToPresent, animated: animated, completion: completion)
        } else {
            print("Never set the view controller before calling transition!")
        }
    }
    
    private func transition<T: SKScene>(to sceneType: T.Type, transition: SKTransition = SKTransition.push(with: .left, duration: 0.35)) {
        if gameViewController != nil {
            let sceneToPresent = sceneType.init(size: gameViewController!.bounds.size)
            sceneToPresent.scaleMode = .aspectFill
            gameViewController!.presentScene(sceneToPresent, transition: transition)
        } else {
            print("Never set the view before calling transition!")
        }
    }
}
