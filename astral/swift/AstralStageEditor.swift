//
//  AstralStageEditor.swift
//  astral
//
//  Created by Joseph Haygood on 7/23/23.
//

import Foundation
import SpriteKit


//
//    Debug views outside their parent frame
/*
extension UIView {
    @objc func reportSuperviews(filtering:Bool = true) {
        var currentSuper : UIView? = self.superview
        print("reporting on \(self)\n")
        while let ancestor = currentSuper {
            let ok = ancestor.bounds.contains(ancestor.convert(self.frame, from: self.superview))
            let report = "it is \(ok ? "inside" : "OUTSIDE") \(ancestor)\n"
            if !filtering || !ok { print(report) }
            currentSuper = ancestor.superview
        }
    }
}
*/



class AstralStageEditor: SKScene, SKPhysicsContactDelegate {
    private var state : AstralGameStateManager!
    private var toolbar : AstralStageEditorToolbar?
    private var player : AstralPlayer?
    private var joystick: AstralJoystick!
    private var collisionHandler : AstralCollisionHandler?
    private var panGestureHandler : UIPanGestureRecognizer?
    private var toolbarBgColor : UIColor?
    private var backgrounds : [AstralParallaxBackgroundLayer2] = []
    private var progress: CGFloat            = 0.0
    private var timeScale: CGFloat           = 1.0
    private var lastUpdateTime: TimeInterval = 0.0
    private var isPlaying: Bool              = false
    private var holdingDownFire: Bool        = false



    

    override init(size: CGSize) {
        super.init(size: size)
        self.toolbar = AstralStageEditorToolbar(frame: .zero, scene: self)
        setupToolbar()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLayerAdded(_:)), name: .layerAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(play(_:)), name: .playMap, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stop(_:)), name: .stopMap, object: nil)
        self.state = AstralGameStateManager.shared
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupToolbar()
        self.toolbarBgColor = toolbar?.backgroundColor
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
        
        toolbar?.setButtons([stageButton, transitionButton, pathButton, enemyButton])
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.addSubview(toolbar!)
        toolbar?.layer.zPosition = 2
        toolbar?.frame.origin.x = view.frame.size.width
        
        self.panGestureHandler = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGestureHandler!)

        toolbar?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar!.topAnchor.constraint(equalTo: self.view!.topAnchor),
            toolbar!.bottomAnchor.constraint(equalTo: self.view!.bottomAnchor),
            toolbar!.leftAnchor.constraint(equalTo: self.view!.rightAnchor),
            toolbar!.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        toolbar?.createSubBar()
        view.addSubview(toolbar!.toolbarSubMenu)
        
        toolbar?.toolbarSubMenu.translatesAutoresizingMaskIntoConstraints = false
        toolbar?.toolbarSubMenu.leftConstraint = toolbar?.toolbarSubMenu.leftAnchor.constraint(equalTo: self.toolbar!.rightAnchor)
        NSLayoutConstraint.activate([
            toolbar!.toolbarSubMenu.leftConstraint,
            toolbar!.toolbarSubMenu.topAnchor.constraint(equalTo: self.toolbar!.topAnchor),
            toolbar!.toolbarSubMenu.widthAnchor.constraint(equalToConstant: 224),
            toolbar!.toolbarSubMenu.heightAnchor.constraint(equalTo: self.toolbar!.heightAnchor)
        ])
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
            toolbar?.validGestureStarted = true
        }
        
        guard toolbar!.validGestureStarted else { return }

        let translation = gesture.translation(in: self.view)
        
        switch gesture.state {
        case .began, .changed:
            var newFrame = toolbar!.frame
            newFrame.origin.x += translation.x
            newFrame.origin.x = max(newFrame.origin.x, self.view!.frame.size.width - fullToolbarWidth)
            
            toolbar?.frame = newFrame
            let newOriginX = max(toolbar!.frame.origin.x + translation.x, self.view!.frame.size.width - fullToolbarWidth)
            let delta = newOriginX - toolbar!.frame.origin.x
            self.toolbar?.toolbarSubMenu.frame.origin.x += delta
            
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

            self.setContentAlpha(mainToolbarOpacity)
            toolbar?.toolbarSubMenu.alpha = subToolbarOpacity

            if swipeDistance < subMenuThreshold {
                toolbar?.snapCursorToButton(at: touchLocation)
            }
            
            /*
                Close the sub menu
             
            if toolbar.subMenuIsOpen {
                let rightSwipe = translation.x > 0
                let rightSwipeDistance = min(translation.x, 32)
                var closedToolbarPosition = self.view!.frame.size.width

                if rightSwipe {
                    if rightSwipeDistance >= 32 {
                        hideToolbar()
                    } else {
                        // Animate the toolbar as if it's closing but don't close
                        // closedToolbarPosition -= (fullToolbarWidth - rightSwipeDistance)
                    }
                }
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.toolbar.frame.origin.x = closedToolbarPosition
                })
            }
            */
            
            self.view!.layoutIfNeeded()
            gesture.setTranslation(.zero, in: self.view)
            
        case .ended, .cancelled:
            if rightEdge - toolbar!.frame.origin.x >= subMenuThreshold {
                revealToolbar()
            } else {
                hideToolbar()
            }
        default:
            break
        }

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            toolbar?.validGestureStarted = false
        }
    }

    
    func setContentAlpha(_ alpha: CGFloat) {
        self.toolbar?.stackView.arrangedSubviews.forEach { $0.alpha = alpha }
        self.toolbar?.selectionCursor.alpha = alpha
        let r = CGFloat( 24 / 255.0 )
        let g = CGFloat( 32 / 255.0 )
        let b = CGFloat( 48 / 255.0 )
        let a = alpha
        self.toolbar!.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a)
        self.toolbar!.backgroundColor = backgroundColor
    }
    
    func revealToolbar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.setContentAlpha(0)
            self.toolbar?.toolbarSubMenu.alpha = 1
            self.toolbar!.frame.origin.x = self.view!.frame.size.width - (224 + 64)
            self.toolbar?.toolbarSubMenu.frame.origin.x = self.view!.frame.size.width - 224
        }, completion: { _ in
            self.toolbar?.subMenuIsOpen = true
        } )
    }

    
    func hideToolbar() {
        UIView.animate(withDuration: 0.25, animations: {
            self.setContentAlpha(1)
            self.toolbar?.toolbarSubMenu.alpha = 0
            self.toolbar!.frame.origin.x = self.view!.frame.size.width
            self.toolbar?.toolbarSubMenu.frame.origin.x = self.view!.frame.size.width + self.toolbar!.frame.width
        }, completion: { _ in
            self.toolbar?.subMenuIsOpen = false
        } )
    }
    
    //
    // Handle ".layerAdded" messages sent by AstralParallaxBackgroundLayerPicker
    //
    @objc private func handleLayerAdded(_ notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let layer = userInfo["layer"] as? AstralParallaxBackgroundLayer2 {
            layer.removeFromParent()
            self.backgrounds.append(layer)
            self.addChild(layer)
            layer.reset()
        }
    }
    
    @objc private func play(_ notification: NSNotification) {
        isPlaying = true
    }

    @objc private func stop(_ notification: NSNotification) {
        isPlaying = false
        for bg in backgrounds {
            bg.reset()
        }
        progress = 0.0  // Resetting the stage
    }
        
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if isPlaying {
            self.progress += deltaTime * timeScale
            for bg in backgrounds {
                bg.update(deltaTime: deltaTime)
            }
        }
    }
}
