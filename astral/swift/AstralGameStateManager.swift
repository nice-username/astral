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
    var editorStateView: AstralStageEditorStateView?

    public init() {}
    
    var gameView: SKView?
    var editorState: AstralStageEditorState?
    var viewController: UIViewController?
    var pathManagerView: AstralStageEditorPathManagerViewController = AstralStageEditorPathManagerViewController(minHeight: 96, maxHeight: 288, titleText: "Path Manager")
    var stageHeight: Double = 0.0
    
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
    
    func editorTransitionTo(_ state: AstralStageEditorState) {
        self.editorState = state
        if state != .selectingPathToEdit {
            dismissPathManager()
        }
        updateEditorStateView()
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
            self.gameView!.window!.layer.add(transition, forKey: kCATransition)
            viewControllerToPresent.modalPresentationStyle = .fullScreen
            viewControllerToPresent.isModalInPresentation = true
            presentingViewController.present(viewControllerToPresent, animated: false, completion: nil)
            // presentingViewController.present(viewControllerToPresent, animated: animated, completion: completion)
        } else {
            print("Never set the view controller before calling transition!")
        }
    }
    
    private func transition<T: SKScene>(to sceneType: T.Type, transition: SKTransition = SKTransition.push(with: .left, duration: 0.35)) {
        if gameView != nil {
            let sceneToPresent = sceneType.init(size: gameView!.bounds.size)
            sceneToPresent.scaleMode = .aspectFill
            gameView!.presentScene(sceneToPresent, transition: transition)
        } else {
            print("Never set the view before calling transition!")
        }
    }
    
    
    func presentPathManager() {
        guard let presentingViewController = viewController else {
            print("No presenting view controller set")
            return
        }

        // Prepare the child view controller
        presentingViewController.addChild(pathManagerView)
        pathManagerView.view.frame = CGRect(x: 0,
                                        y: presentingViewController.view.bounds.height,
                                        width: presentingViewController.view.bounds.width,
                                        height: presentingViewController.view.bounds.height)
        presentingViewController.view.addSubview(pathManagerView.view)

        // Animate the presentation
        UIView.animate(withDuration: 0.35, animations: {
            self.pathManagerView.view.frame = presentingViewController.view.bounds
        }, completion: { _ in
            self.pathManagerView.didMove(toParent: presentingViewController)
        })
    }

    func dismissPathManager() {
        UIView.animate(withDuration: 0.70, animations: { [self] in
            pathManagerView.hideMenu()
            pathManagerView.view.frame = CGRect(x: 0,
                                            y: self.viewController!.view.bounds.height,
                                            width: pathManagerView.view.frame.width,
                                            height: pathManagerView.view.frame.height)
        }, completion: { _ in
            self.pathManagerView.willMove(toParent: nil)
            self.pathManagerView.view.removeFromSuperview()
            self.pathManagerView.removeFromParent()
        })
    }
    
    
    func updateEditorStateView() {
        guard let state = editorState else { return }
        
        let message: String
        var icon: UIImage? = nil
        
        switch state {
        case .idle:
            message = "Idle"
        case .selectingPathToEdit, .selectingPathToAppend:
            message = "Selecting Path"
            icon = UIImage(named: "path_tool")
        case .drawingNewPath:
            message = "Drawing new path"
            icon = UIImage(named: "path_tool")
        case .appendingToPath:
            message = "Appending to path"
            icon = UIImage(named: "path_tool")
        case .editingNode:
            message = ""
        case .editingBezier:
            message = ""
        case .selectingNodeType:
            message = "Select node type"
            icon = UIImage(named: "add_to_path")
        case .selectingNodeActionType:
            message = "Select action"
            icon = UIImage(named: "path_select")   
        case .selectingNodeCreationMenu:
            message = "Editing creation node"
            icon = UIImage(named: "path_select")
        case .placingCreationNode:
            message = "Placing creation node"
            icon = UIImage(named: "add_to_path")
        case .placingActionNode:
            message = "Placing action node"
            icon = UIImage(named: "add_to_path")
        case .placingPathingNode:
            message = "Placing pathing node"
            icon = UIImage(named: "add_to_path")
        case .movingPath:
            message = "Moving path"
            icon = UIImage(named: "path_tool")
        }
        
        if icon != nil {
            icon = icon?.invertedImage()
        }
        DispatchQueue.main.async { [weak self] in
            self?.editorStateView?.configure(with: icon, message: message)
        }
    }

}
