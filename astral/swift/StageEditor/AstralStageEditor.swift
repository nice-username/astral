//
//  AstralStageEditor.swift
//  astral
//
//  Created by Joseph Haygood on 7/23/23.
//

import Foundation
import SpriteKit

class AstralStageEditor: SKScene, SKPhysicsContactDelegate {
    private var gameState : AstralGameStateManager!
    private var toolbar : AstralStageEditorToolbar?
    private var player : AstralPlayer?
    private var joystick : AstralJoystick!
    private var collision : AstralCollisionHandler?
    private var fileManager : AstralStageFileManager = AstralStageFileManager()
    private var input : AstralInputHandler?
    private var metadata : AstralStageMetadata?
    private var stageName : String = ""
    private var panGestureHandler : UIPanGestureRecognizer?
    private var stageScrollRecognizer: UIPanGestureRecognizer!
    private var toolbarBgColor : UIColor?
    private var backgrounds : [AstralParallaxBackgroundLayer2] = []
    
    
    // Stage playback
    private var progress: CGFloat            = 0.0
    private var timeScale: CGFloat           = 1.0
    private var lastUpdateTime: TimeInterval = 0.0
    private var isPlaying: Bool              = false
    private var fireButton : SKSpriteNode?
    
    // Path drawing
    private var pathInput : AstralStageEditorPathInputHandler!
    private var pathManager = AstralStageEditorPathManager()
    private var pathRenderer: AstralStageEditorPathRenderer!
    
    // test
    private var pathManagerView : AstralStageEditorPathManagerViewController?
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
        self.gameState = AstralGameStateManager.shared
        
        self.gameState.stageHeight = 1000.0
        self.size = CGSize(width: 750.0, height: 1334.0)
        self.backgroundColor = .black
        
        
        self.toolbar = AstralStageEditorToolbar(frame: .zero, scene: self)
        setupToolbar()
        self.toolbarBgColor = toolbar?.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(handleLayerAdded(_:)), name: .layerAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(play(_:)), name: .playMap, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stop(_:)), name: .stopMap, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveStage(_:)), name: .saveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pathApplyChanges(_:)), name: .pathApplyChanges, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pathAddToScene(_:)), name: .pathAddToScene, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadStage(_:)), name: .loadFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideToolbar(_:)), name: .hideToolbar, object: nil)
        
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
        
        self.pathRenderer = AstralStageEditorPathRenderer(scene: self)
        self.pathManagerView = AstralStageEditorPathManagerViewController(minHeight: 96, maxHeight: 384)
        self.pathInput = AstralStageEditorPathInputHandler(pathManager: pathManager, pathRenderer: pathRenderer)
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
        panGestureHandler?.minimumNumberOfTouches = 1
        panGestureHandler?.maximumNumberOfTouches = 1
        panGestureHandler?.cancelsTouchesInView = false
        view.addGestureRecognizer(panGestureHandler!)
        
        // Event handler for scrolling up and down a stage:
        stageScrollRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleStageScroll(_:)))
        stageScrollRecognizer.minimumNumberOfTouches = 2
        stageScrollRecognizer.maximumNumberOfTouches = 2
        stageScrollRecognizer?.cancelsTouchesInView = false
        view.addGestureRecognizer(stageScrollRecognizer)

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

    // Handle the stage scroll pan gesture
    @objc private func handleStageScroll(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            scrollStage(by: translation.y)
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        case .ended:
            let velocityY = recognizer.velocity(in: recognizer.view).y
            decelerateScroll(withVelocity: velocityY)
        default:
            break
        }
    }
    
    // ChatGPT black magic deceleration algo
    func decelerateScroll(withVelocity velocity: CGFloat) {
        var currentVelocity = velocity
        // Adjust this value as needed:
        let decelerationRate = CGFloat(0.90)
        Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let deltaY = currentVelocity / 60.0
            self.scrollStage(by: deltaY)
            if abs(currentVelocity) < 1.0 {
                timer.invalidate()
            }
            currentVelocity *= decelerationRate
        }
    }
    
    func scrollStage(by deltaY: CGFloat) {
        backgrounds.forEach { $0.update(deltaTime: 0, gestureYChange: deltaY) }
        updateEditorProgress(gestureDistance: deltaY)
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

    @objc private func hideToolbar(_ notification: NSNotification) {
        self.hideToolbar()
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
    // Handle ".pathAddToScene" messages sent by any given path
    //
    @objc private func pathAddToScene(_ notification: NSNotification) {
        if let data = notification.userInfo, let segment = data["segment"] as? AstralPathSegment {
            scene?.addChild(segment.shape!)
            scene?.addChild(segment.directionArrow!)
        }
    }
    
    
    //
    // Handle ".pathApplyChanges" messages sent by the toolbar
    //
    @objc private func pathApplyChanges(_ notification: NSNotification) {
        if let data = notification.userInfo, let path = data["path"] as? AstralStageEditorPath {
            pathManager.savePathData(path: path)
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
        progress = 0.0
        for bg in backgrounds {
            bg.reset()
        }
        
        isPlaying = true
        self.addChild(player!)
        self.addChild(fireButton!)
        self.togglePaths(show: false)
        
        let enemy = AstralEnemy(scene: self, maxHP: 20)
        if !self.pathManager.paths.isEmpty {
            enemy.position = pathManager.paths[0].segments[0].startPoint()
            enemy.followPath(pathManager.paths[0])
        }
    }

    @objc private func stop(_ notification: NSNotification) {
        isPlaying = false
        player!.removeFromParent()
        fireButton?.removeFromParent()
        self.togglePaths(show: true)
        for bg in backgrounds {
            bg.reset()
        }
        progress = 0.0
    }
    
    //
    // Set progress based on scroll gesture
    //
    func updateEditorProgress(gestureDistance: CGFloat) {
        // Adjust based on game speed and FPS (60 FPS assumed)
        let progressPerFrame = timeScale / 60 // Assuming deltaTime is 1/60 for 60 FPS
        progress += gestureDistance * progressPerFrame
        self.pathManager.updatePathActivation(progress: self.progress)
        print(self.progress)
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
            self.progress = min(self.progress + deltaTime * timeScale, gameState.stageHeight)
            input?.update(currentTime, deltaTime: deltaTime)
            for bg in backgrounds {
                bg.update(deltaTime: deltaTime, gestureYChange: 0)
            }
            self.pathManager.updatePathActivation(progress: self.progress)
        }
    }
    
    
    //
    // Handle collision
    //
    func didBegin(_ contact: SKPhysicsContact) {
        self.collision?.handleContact(contact: contact)
    }
    
    //
    // Set path visibility
    //
    private func togglePaths(show: Bool) {
        for path in pathManager.paths {
            for segment in path.segments {
                segment.shape?.isHidden = !show
                segment.directionArrow?.isHidden = !show
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            input!.touchesBegan(touches, with: event)
        }
        
        // Handle user using path drawing tool
        if toolbar?.selectedSubmenuType == .path {
            pathInput.touchesBegan(touches, in: self)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            input!.touchesMoved(touches, with: event)
        }
                
        if toolbar?.selectedSubmenuType == .path {
            pathInput.touchesMoved(touches, in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying {
            input!.touchesEnded(touches, with: event)
        }
        
        if toolbar?.selectedSubmenuType == .path {
            pathInput.touchesEnded(touches, in: self)
        }
    }
}
