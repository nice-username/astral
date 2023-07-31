//
//  AstralStageEditor.swift
//  astral
//
//  Created by Joseph Haygood on 7/23/23.
//

import Foundation
import SpriteKit

class AstralStageEditor: SKScene {
    let toolbar = AstralStageEditorToolbar(frame: CGRect(x: 0, y: 0, width: 64, height: UIScreen.main.bounds.height))

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        if let viewController = view.window?.rootViewController {
            viewController.view.addSubview(toolbar)
            toolbar.frame.origin.x = self.view!.frame.size.width

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            view.addGestureRecognizer(panGesture)
        }
        
        /*
        let stageButton = AstralStageEditorToolbarButton(icon: UIImage(named: "file")!) {
            self.handleAction(.stageMenu)
        }

        let transitionButton = AstralStageEditorToolbarButton(icon: UIImage(named: "transition")!) {
            self.handleAction(.transitionMenu)
        }

        let pathButton = AstralStageEditorToolbarButton(icon: UIImage(named: "path_tool")!) {
            self.handleAction(.pathMenu)
        }

        let enemyButton = AstralStageEditorToolbarButton(icon: UIImage(named: "enemy")!) {
            self.handleAction(.enemyMenu)
        }

        let buttons = [stageButton, transitionButton, pathButton, enemyButton]
        toolbar.setToolSubViews(buttons)
        */
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self.view)
        
        // Only respond to touches that begin within 64 points of the right edge of the screen
        let rightEdge = self.view!.frame.size.width
        if gesture.state == .began && rightEdge - touchLocation.x <= 64 {
            toolbar.validGestureStarted = true
        }
        
        guard toolbar.validGestureStarted else {
            return
        }
        
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view).x.rounded()
        
        switch gesture.state {
        case .began, .changed:
            // Adjust the frame of the toolbar, restricting the x position to the right edge of the screen
            var newFrame = toolbar.frame
            newFrame.origin.x += translation.x
            newFrame.origin.x = max(newFrame.origin.x, self.view!.frame.size.width - toolbar.frame.size.width)
            
            toolbar.frame = newFrame
            gesture.setTranslation(.zero, in: self.view)
            
        case .ended:
            if(velocity > 500) {
                hideToolbar()
            } else if toolbar.frame.origin.x < self.view!.frame.size.width - 32 || velocity < -500 {
                revealToolbar()
            } else {
                hideToolbar()
            }
            
        default:
            break
        }
        
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            toolbar.validGestureStarted = false
        }
    }

    func handleAction(_ action: AstralStageEditorAction) {
        switch action {
        case .stageMenu:
            print("menu 1")
        case .transitionMenu:
            print("menu 2")
        case .pathMenu:
            print("menu 3")
        case .enemyMenu:
            print("menu 4")
        case .stageCreate:
            print("Stage create")
        case .stageRename:
            print("action")
        case .stageSave:
            print("action")
        case .stageLoad:
            print("action")
        case .stageExit:
            print("action")
        case .stageLength:
            print("action")
        case .stageBackground:
            print("action")
        case .transitionLocation:
            print("action")
        case .transitionArt:
            print("action")
        case .transitionAnimation:
            print("action")
        case .pathCreate:
            print("action")
        case .pathExtend:
            print("action")
        case .pathTrim:
            print("action")
        case .pathRemove:
            print("action")
        case .pathMove:
            print("action")
        case .pathAdjustShape:
            print("action")
        case .pathAddNode:
            print("action")
        case .pathRemoveNode:
            print("action")
        case .pathEditNodeAction:
            print("action")
        case .enemySelectType:
            print("action")
        case .enemyTypeProperties:
            print("action")
        case .enemyAddToPath:
            print("action")
        case .enemyDelete:
            print("action")
        }
    }

    func revealToolbar() {
        UIView.animate(withDuration: 0.125) {
            self.toolbar.frame.origin.x = self.view!.frame.size.width - self.toolbar.frame.size.width
        }
    }

    func hideToolbar() {
        UIView.animate(withDuration: 0.125) {
            self.toolbar.frame.origin.x = self.view!.frame.size.width
        }
    }
}
