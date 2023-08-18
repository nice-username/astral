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
    public var toolbarBgColor : UIColor?

    override init(size: CGSize) {
        super.init(size: size)
        setupToolbar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupToolbar()
        self.toolbarBgColor = toolbar.backgroundColor
    }
    
    func setupToolbar() {
        let stageButton = AstralStageEditorToolbarButton(icon: UIImage(named: "file_tool")!,
                                                         action: { print("stage button tapped") },
                                                         type: .topLevel,
                                                         submenuType: .file)
        
        let transitionButton = AstralStageEditorToolbarButton(icon: UIImage(named: "transition")!,
                                                              action: { print("transition button tapped") },
                                                              type: .topLevel,
                                                              submenuType: .transition)
        
        let pathButton = AstralStageEditorToolbarButton(icon: UIImage(named: "path_tool")!,
                                                        action: { print("path button tapped") },
                                                        type: .topLevel,
                                                        submenuType: .path)
        
        let enemyButton = AstralStageEditorToolbarButton(icon: UIImage(named: "enemy")!,
                                                         action: { print("enemy button tapped") },
                                                         type: .topLevel,
                                                         submenuType: .enemy)
        
        toolbar.setButtons([stageButton, transitionButton, pathButton, enemyButton])
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.addSubview(toolbar)
        toolbar.layer.zPosition = 2
        toolbar.frame.origin.x = view.frame.size.width
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
    }
    
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self.view)
        
        // Constants
        let rightEdge = self.view!.frame.size.width
        let mainToolbarThreshold: CGFloat = 64
        let subMenuThreshold: CGFloat = 96
        let fullToolbarWidth: CGFloat = 224 + 64

        // Initial touch detection
        if gesture.state == .began && rightEdge - touchLocation.x <= mainToolbarThreshold {
            toolbar.validGestureStarted = true
        }
        
        guard toolbar.validGestureStarted else { return }

        let translation = gesture.translation(in: self.view)
        
        switch gesture.state {
        case .began, .changed:
            var newFrame = toolbar.frame
            newFrame.origin.x += translation.x
            newFrame.origin.x = max(newFrame.origin.x, self.view!.frame.size.width - fullToolbarWidth)
            
            toolbar.frame = newFrame
            
            let swipeDistance = rightEdge - newFrame.origin.x
            let mainToolbarOpacity: CGFloat
            let subToolbarOpacity: CGFloat

            if swipeDistance <= mainToolbarThreshold {
                mainToolbarOpacity = 1
                subToolbarOpacity = 0
            } else if swipeDistance <= 192 { // Use 192px as the threshold for full sub-toolbar opacity
                let subToolbarRange: CGFloat = 192 - mainToolbarThreshold
                subToolbarOpacity = (swipeDistance - mainToolbarThreshold) / subToolbarRange
                mainToolbarOpacity = 1 - subToolbarOpacity
            } else {
                mainToolbarOpacity = 0
                subToolbarOpacity = 1
            }

            toolbar.stackView.alpha = mainToolbarOpacity
            toolbar.toolbarSubMenu.alpha = subToolbarOpacity
            toolbar.backgroundColor = self.toolbarBgColor?.withAlphaComponent(mainToolbarOpacity)

            if swipeDistance < subMenuThreshold {
                toolbar.snapCursorToButton(at: touchLocation)
            }
            
            gesture.setTranslation(.zero, in: self.view)
            
        case .ended, .cancelled:
            if rightEdge - toolbar.frame.origin.x >= subMenuThreshold {
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

    
    func closeSubMenu() {
        toolbar.secondaryToolbarOpened = false
    }
    
    func revealToolbar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.toolbar.stackView.alpha = 0
            self.toolbar.selectionCursor.alpha = 0
            self.toolbar.backgroundColor = .none
            self.toolbar.toolbarSubMenu.alpha = 1
            self.toolbar.frame.origin.x = self.view!.frame.size.width - (224 + 64)
        })
    }

    
    func hideToolbar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.toolbar.stackView.alpha = 1
            self.toolbar.selectionCursor.alpha = 1
            let r = CGFloat( 24 / 255.0 )
            let g = CGFloat( 32 / 255.0 )
            let b = CGFloat( 48 / 255.0 )
            let a = CGFloat( 255 / 255.0 )
            self.toolbar.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a)
            self.toolbar.toolbarSubMenu.alpha = 0
            self.toolbar.frame.origin.x = self.view!.frame.size.width
        })
    }
}
