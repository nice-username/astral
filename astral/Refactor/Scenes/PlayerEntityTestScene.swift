//
//  PlayerEntityTestScene.swift
//  astral
//
//  Created by Joseph Haygood on 2/17/25.
//

import Foundation
import SpriteKit
import GameplayKit

class PlayerEntityTestScene: SKScene {
    private var playerEntity: AstralPlayerEntity?
    private var joystick: AstralJoystick!
    private var lastUpdateTime: TimeInterval = 0

    // Track joystick touch for turning calculation
    private var joystickTouch: UITouch?
    private var touchStartPosition: CGPoint?

    override func sceneDidLoad() {
        super.sceneDidLoad()
        backgroundColor = .black
        self.size = CGSize(width: 750.0, height: 1334.0)

        setupPhysics()
        setupJoystick()
        setupPlayer()
        setupUI()
    }

    private func setupPhysics() {
        physicsWorld.gravity = .zero

        let xOffset: CGFloat = 80.0
        let bounds = CGRect(
            x: frame.minX + (xOffset / 2.0),
            y: frame.minY,
            width: size.width - xOffset,
            height: size.height
        )
        let body = SKPhysicsBody(edgeLoopFrom: bounds)
        body.categoryBitMask = AstralPhysicsCategory.boundary
        body.collisionBitMask = AstralPhysicsCategory.boundary
        self.physicsBody = body
    }

    private func setupJoystick() {
        joystick = AstralJoystick()
        joystick.zPosition = 10
        addChild(joystick)
    }

    private func setupPlayer() {
        let startPosition = CGPoint(x: size.width / 2, y: size.height / 4)
        playerEntity = AstralPlayerEntity(scene: self, position: startPosition, joystick: joystick)

        if let sprite = playerEntity?.node as? SKSpriteNode {
            sprite.xScale = 2.0
            sprite.yScale = 2.0
        }
    }

    private func setupUI() {
        let instructions = SKLabelNode(text: "Drag left side to move | Tap right side for polarity")
        instructions.fontSize = 16
        instructions.fontName = "Helvetica"
        instructions.fontColor = .white
        instructions.position = CGPoint(x: size.width / 2, y: size.height - 80)
        instructions.zPosition = 10
        addChild(instructions)

        let stateLabel = SKLabelNode(text: "Polarity: White")
        stateLabel.fontSize = 16
        stateLabel.fontName = "Helvetica"
        stateLabel.fontColor = .white
        stateLabel.position = CGPoint(x: size.width / 2, y: 60)
        stateLabel.zPosition = 10
        stateLabel.name = "stateLabel"
        addChild(stateLabel)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        playerEntity?.update(deltaTime: deltaTime)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Right half = polarity switch
        if location.x > size.width / 2 {
            switchPolarity()
        } else {
            // Left half = joystick control
            joystickTouch = touch
            touchStartPosition = location
            joystick.touchesBegan(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch, let startPos = touchStartPosition {
                let currentPos = touch.location(in: self)

                // Calculate horizontal drag as -1 to 1 based on screen width
                let dx = currentPos.x - startPos.x
                let screenWidth = UIScreen.main.bounds.width
                let input = -(dx / screenWidth)

                // Update player sprite based on drag
                playerEntity?.setSprite(inputValue: input)
            }
        }

        joystick.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                // Animate back to resting position
                playerEntity?.animateToRestingPosition(duration: 0.4)
                joystickTouch = nil
                touchStartPosition = nil
            }
        }

        joystick.touchesEnded(touches, with: event)
    }

    private func switchPolarity() {
        guard let entity = playerEntity else { return }

        entity.switchPolarity()

        if let label = childNode(withName: "stateLabel") as? SKLabelNode,
           let polarity = entity.getCurrentPolarity() {
            label.text = "Polarity: \(polarity == .white ? "White" : "Black")"
        }
    }
}

// MARK: - Scene Setup
extension PlayerEntityTestScene {
    static func createScene() -> PlayerEntityTestScene {
        let scene = PlayerEntityTestScene()
        scene.scaleMode = .resizeFill
        return scene
    }
}
