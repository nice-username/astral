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
    private var collision : AstralCollisionHandler?
    private var fileManager : AstralStageFileManager = AstralStageFileManager()
    private var input : AstralInputHandler?
    private var metadata : AstralStageMetadata?
    private var stageName : String = ""
    private var panGestureHandler : UIPanGestureRecognizer?
    private var toolbarBgColor : UIColor?
    private var backgrounds : [AstralParallaxBackgroundLayer2] = []
    // Stage playback
    private var progress: CGFloat            = 0.0
    private var timeScale: CGFloat           = 1.0
    private var lastUpdateTime: TimeInterval = 0.0
    private var isPlaying: Bool              = false
    private var fireButton : SKSpriteNode?
    
    // Path drawing
    private var path = AstralStageEditorPath()
    private var pathRenderer: AstralPathRenderer!
    private var pathStart: CGPoint?
    private var pathOrigin: CGPoint?
    private var isFirstPath : Bool = true

    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    override func sceneDidLoad() {
        self.size = CGSize(width: 750.0, height: 1334.0)
        self.backgroundColor = .black
        
        self.toolbar = AstralStageEditorToolbar(frame: .zero, scene: self)
        setupToolbar()
        self.toolbarBgColor = toolbar?.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(handleLayerAdded(_:)), name: .layerAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(play(_:)), name: .playMap, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stop(_:)), name: .stopMap, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveStage(_:)), name: .saveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadStage(_:)), name: .loadFile, object: nil)
        self.state = AstralGameStateManager.shared
        
        self.collision = AstralCollisionHandler()
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        self.createBoundaries()
        
        self.player = AstralPlayer(scene: self)
        self.player?.xScale = 1.5
        self.player?.yScale = 1.5        
        self.collision?.player = self.player
        
        self.player?.position.x += self.frame.width / 2.0
        self.player?.position.y += self.frame.height / 5.0
        joystick = AstralJoystick()
        self.addChild(joystick)
        
        self.input = AstralInputHandler(scene: self, player: player!, joystick: joystick)
        
        fireButton = SKSpriteNode(imageNamed: "ui_fire_button_up")        
        fireButton!.xScale = 3
        fireButton!.yScale = 3
        fireButton!.texture?.filteringMode = .nearest
        fireButton?.position.x += self.frame.width / 4
        fireButton?.position.y += self.frame.height / 8 - 64
        fireButton?.zPosition = 2
        input?.fireButton = fireButton
        joystick.zPosition = 2
        
        fileManager = AstralStageFileManager()
        metadata = AstralStageMetadata(name: "stage1",
                                       author: "me",
                                       description: "stage1",
                                       dateCreated: Date(),
                                       dateOpened: Date(),
                                       dateModified: Date() )
        
        self.pathRenderer = AstralPathRenderer(scene: self)
    }
    
    
    private func createBoundaries() {
        let xOffset = 80.0
        let bounds = CGRect(x: self.frame.minX + (xOffset / 2.0), y: self.frame.minY, width: self.size.width - xOffset, height: self.size.height)
        let body = SKPhysicsBody(edgeLoopFrom: bounds)
        body.categoryBitMask = AstralPhysicsCategory.boundary
        body.collisionBitMask = AstralPhysicsCategory.boundary
        body.contactTestBitMask = AstralPhysicsCategory.bulletPlayer | AstralPhysicsCategory.bulletEnemy | AstralPhysicsCategory.enemy | AstralPhysicsCategory.player
        self.physicsBody = body
    }
    
        
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.addSubview(toolbar!)
        toolbar?.layer.zPosition = 2
        toolbar?.frame.origin.x = view.frame.size.width
        
        self.panGestureHandler = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGestureHandler?.cancelsTouchesInView = false
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
            layer.xScale = 1.5
            layer.yScale = 1.5
            layer.position.x += layer.getWidth() / 3
            layer.reset()
        }
    }
    
    //
    // Handle ".saveFile" messages sent by the toolbar
    //
    @objc private func saveStage(_ notification: NSNotification) {
        let metadata = AstralStageMetadata(name: self.stageName,
                                           author: "",
                                           description: "",
                                           dateCreated: Date(),
                                           dateOpened: Date(),
                                           dateModified: Date())
        
        // Convert each AstralParallaxBackgroundLayer to AstralParallaxBackgroundLayerData
        let backgroundDataArray = backgrounds.map { layer in
            return AstralParallaxBackgroundLayerData(
                atlasName: layer.getAtlasName(),
                scrollingSpeed: layer.getSpeed(),
                scrollingDirection: layer.getDirection(),
                shouldLoop: layer.getLoopFlag()
            )
        }
        
        // Create AstralStageData object
        let stage = AstralStageData(metadata: metadata, backgrounds: backgroundDataArray)
        
        // Save the stage
        fileManager.saveStage(stageData: stage, filename: "Stage1.json")
    }
    
    
    //
    // Handle ".loadFile" messages sent by the toolbar
    //
    @objc private func loadStage(_ notification: NSNotification) {
        // Load the stage
        if let loadedStage = fileManager.loadStage(filename: "Stage1.json") {
            // Load Metadata
            self.metadata?.name = loadedStage.metadata.name
            self.metadata?.author = loadedStage.metadata.author
            self.metadata?.description = loadedStage.metadata.description
            self.metadata?.dateCreated = loadedStage.metadata.dateCreated
            self.metadata?.dateModified = loadedStage.metadata.dateModified
            self.metadata?.dateOpened = Date()
            
            // Remove existing backgrounds from SKScene and clear array
            for background in self.backgrounds {
                background.removeFromParent()
            }
            self.backgrounds.removeAll()
            
            // Load Backgrounds
            for backgroundData in loadedStage.backgrounds {
                let newBackgroundLayer = AstralParallaxBackgroundLayer2(
                    atlasNamed: backgroundData.atlasName,
                    direction: backgroundData.scrollingDirection,
                    speed: backgroundData.scrollingSpeed,
                    shouldLoop: backgroundData.shouldLoop
                )
                newBackgroundLayer.xScale = 1.5
                newBackgroundLayer.yScale = 1.5
                newBackgroundLayer.position.x += newBackgroundLayer.getWidth() / 1.5
                newBackgroundLayer.position.y += newBackgroundLayer.getHeight() / 3
                self.backgrounds.append(newBackgroundLayer)
                 
                // Add new background layers to your SKScene
                self.addChild(newBackgroundLayer)
            }
        } else {
            print("Failed to load stage.")
        }
    }

    
    
    
    @objc private func play(_ notification: NSNotification) {
        isPlaying = true
        self.addChild(player!)
        self.addChild(fireButton!)
    }

    @objc private func stop(_ notification: NSNotification) {
        isPlaying = false
        player!.removeFromParent()
        fireButton?.removeFromParent()
        for bg in backgrounds {
            bg.reset()
        }
        progress = 0.0
    }
    
    
    //
    // Called each game tick
    //
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if isPlaying {
            self.progress += deltaTime * timeScale
            input?.update(currentTime, deltaTime: deltaTime)
            for bg in backgrounds {
                bg.update(deltaTime: deltaTime)
            }
        }
    }
    
    
    //
    // Handle collision
    //
    func didBegin(_ contact: SKPhysicsContact) {
        self.collision?.handleContact(contact: contact)
    }
    
    
    
    // TODO: this functionality and related variables seem like they should be tied to a different class
    func getPathStart(fallback: CGPoint) -> CGPoint {
        var start: CGPoint
        if isFirstPath {
            start = pathStart ?? fallback // Fallback if pathStart is nil for some reason
            pathOrigin = start
            isFirstPath = false
        } else {
            // Set start to the endPoint of the last segment in the path
            if let lastSegment = path.segments.last {
                switch lastSegment.type {
                case .line(_, let end):
                    start = end
                case .bezier(_, _, _, let end):
                    start = end
                }
            } else {
                // Fallback if pathOrigin is nil for some reason0
                start = pathOrigin ?? fallback
            }
        }
        return start
    }
    
    
    //
    // Pass all of the gameplay input to a separate file to be dealt with over there...
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            input!.touchesBegan(touches, with: event)
        }
        
        // Start drawing path
        if let touch = touches.first {
            if toolbar?.selectedSubmenuType == .path {
                if path.segments.count == 0 {
                    isFirstPath = true
                } else {
                    isFirstPath = false
                }
                pathStart = touch.location(in: self)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            input!.touchesMoved(touches, with: event)
        }
        
        if toolbar?.selectedSubmenuType == .path {
            if let touch = touches.first {
                let currentPoint = touch.location(in: self)
                let start    = getPathStart(fallback: currentPoint)
                let distance = start.distanceTo(currentPoint)
                 
                // Only draw the temporary line if the user has dragged far enough
                if distance > 10 { // TODO: Replace 10 with a variable for the minimum distance
                    pathRenderer.drawTemporaryLine(from: start, to: currentPoint)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            input!.touchesEnded(touches, with: event)
        }
        
        if toolbar?.selectedSubmenuType == .path {
            if let touch = touches.first {
                let endPoint = touch.location(in: self)
                let start    = getPathStart(fallback: endPoint)
                
                if pathStart != nil {
                    let distance = pathStart!.distanceTo(endPoint)
                    // Only make the line permanent if the user has dragged far enough
                    if distance > 10 {
                        let pathIndex = path.addSegment(type: .line(start: start, end: endPoint))
                        pathRenderer.drawPermanentLines(from: path)
                        pathRenderer.removeTemporaryLine()
                        print("added segment #\(pathIndex)")
                        
                        if isFirstPath {
                            pathOrigin  = start
                            isFirstPath = false
                        } else {
                            // If the endpoint is close to the path's origin, consider the path complete
                            if endPoint.distanceTo(pathOrigin!) < 15 {
                                path.segments.removeAll()
                                print("You fucken finish that bitch")
                                self.pathStart = nil
                                isFirstPath = true
                                // Add path to AstralPathManager
                                // Reset everything
                            }
                        }
                    }
                }
            } else {
                // TODO: Check for 3D touch or longpress to confirm short path ( < 10 )
            }
        }
    }
}
