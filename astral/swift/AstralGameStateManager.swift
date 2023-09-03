//
//  AstralGameStateManager.swift
//  astral
//
//  Created by Joseph Haygood on 5/29/23.
//

import Foundation
import SpriteKit

class AstralGameStateManager {
    static let shared = AstralGameStateManager()
    public init() {}
    
    var gameViewController: SKView?
    var viewController: UIViewController?
    
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
            case .editorPlay:
                self.throwEventMessage(name: .playMap)
                break
            case .editorStop:
                self.throwEventMessage(name: .stopMap)
                break
            case .none:
                break
            }
        }
    }
    
    func transitionTo(_ state: AstralGameState) {
        self.currentState = state
    }
    
    func throwEventMessage(name: NSNotification.Name, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    public func transitionToViewController(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let presentingViewController = viewController {
            
            let transition = CATransition()
            transition.duration = 0.35
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.gameViewController!.window!.layer.add(transition, forKey: kCATransition)
            viewControllerToPresent.modalPresentationStyle = .fullScreen
            viewControllerToPresent.isModalInPresentation = true
            presentingViewController.present(viewControllerToPresent, animated: false, completion: nil)
            // presentingViewController.present(viewControllerToPresent, animated: animated, completion: completion)
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
