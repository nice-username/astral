//
//  AstralJoystick.swift
//  astral
//
//  Created by Joseph Haygood on 4/30/23.
//

import Foundation
import SpriteKit


class AstralJoystick: SKNode {
    private var joystick: SKSpriteNode!
    private var joystickTextures: [Direction: SKTexture] = [:]
    private var touchDownPoint : CGPoint?
    private var deadZoneArea : CGFloat = 12.0
    private var fadeTime : TimeInterval = 0.125
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    var direction: Direction = .none
    var previousDirection: Direction?
    
    override init() {
        super.init()
        
        self.joystick = SKSpriteNode(imageNamed: "base.png")
        self.joystick.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.loadTextures()
        self.xScale = 2.0
        self.yScale = 2.0
        self.alpha  = 0
        self.addChild(joystick)
        
        self.feedback.prepare()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Normalized velocity
    //
    public var normalizedVelocity: CGVector? {
        if self.direction != .none {
            return self.calculateVelocity(from: direction)
        } else {
            return nil
        }
    }
    
    
    public func calculateVelocity(from direction: Direction) -> CGVector {
        let velocityFactor: CGFloat = 1.0
        switch direction {
        case .up:
            return CGVector(dx: 0, dy: velocityFactor)
        case .upRight:
            return CGVector(dx: velocityFactor / sqrt(2), dy: velocityFactor / sqrt(2))
        case .right:
            return CGVector(dx: velocityFactor, dy: 0)
        case .downRight:
            return CGVector(dx: velocityFactor / sqrt(2), dy: -velocityFactor / sqrt(2))
        case .down:
            return CGVector(dx: 0, dy: -velocityFactor)
        case .downLeft:
            return CGVector(dx: -velocityFactor / sqrt(2), dy: -velocityFactor / sqrt(2))
        case .left:
            return CGVector(dx: -velocityFactor, dy: 0)
        case .upLeft:
            return CGVector(dx: -velocityFactor / sqrt(2), dy: velocityFactor / sqrt(2))
        case .none:
            return CGVector.zero
        }
    }
    
    //
    // Velocity
    //
    public var velocity: CGVector? {
        if self.touchDownPoint != nil {
            let dx = (self.joystick.position.x - self.touchDownPoint!.x) * 1.0
            let dy = (self.joystick.position.y - self.touchDownPoint!.y) * 1.0
            return CGVector(dx: dx, dy: dy)
        } else {
            return nil
        }
    }
    
    
    //
    // loadTextures
    //
    func loadTextures() {
        let textureAtlas = SKTextureAtlas(named: "Joystick")
        let directions: [Direction] = [.up, .upRight, .right, .downRight, .down, .downLeft, .left, .upLeft, .none]
        for (index, direction) in directions.enumerated() {
            let textureName: String
            if direction == .none {
                textureName = "base"
            } else {
                textureName = "direction\(String(format: "%02d", index))"
            }
            self.joystickTextures[direction] = textureAtlas.textureNamed(textureName)
            self.joystickTextures[direction]?.filteringMode = .nearest
        }
    }
    
    
    // Override touch event methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchDownPoint = touch.location(in: self)
        self.handleTouches(touches)
        self.removeAction(forKey: "fade")
        self.run(SKAction.fadeIn(withDuration: self.fadeTime), withKey: "fade")
        self.joystick.position = self.touchDownPoint!
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.touchDownPoint != nil {
            self.handleTouches(touches)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset current direction once the player lets go
        self.touchDownPoint = nil
        self.direction = Direction.none
        self.joystick.texture = SKTexture(imageNamed: "base.png")
        self.removeAction(forKey: "fade")
        self.run(SKAction.fadeOut(withDuration: self.fadeTime), withKey: "fade")
    }
    
    
    
    private func handleTouches(_ touches: Set<UITouch>) {
        // First touch counts only.
        guard let touch = touches.first else { return }
        
        // Get point
        let location = touch.location(in: self)
        
        // Determine the direction based on the touch location and the joystick's position
        self.direction = self.calculateDirection(from: location, relativeTo: self.touchDownPoint!)
        
        // Update the joystick texture based on the direction
        if self.direction != .none {
            let paddedRawValue = String(format: "%02d", direction.rawValue)
            self.joystick.texture = SKTexture(imageNamed: "direction\(paddedRawValue).png")
            if direction != self.previousDirection {
                self.feedback.impactOccurred()
            }
        } else {
            self.joystick.texture = SKTexture(imageNamed: "base.png")
            self.previousDirection = nil
        }
        
        // Store the current direction as the previous direction
        self.previousDirection = self.direction
    }


    
    
    private func calculateDirection(from location: CGPoint, relativeTo joystickPosition: CGPoint) -> Direction {
        let deltaX = location.x - joystickPosition.x
        let deltaY = location.y - joystickPosition.y
        
        // No direction if touch is within the deadZone
        if hypot(deltaX, deltaY) < self.deadZoneArea {
            return .none
        }
        
        let angle = atan2(deltaY, deltaX)
        
        if angle >= -CGFloat.pi / 8 && angle < CGFloat.pi / 8 {
            return .right
        } else if angle >= CGFloat.pi / 8 && angle < 3 * CGFloat.pi / 8 {
            return .upRight
        } else if angle >= 3 * CGFloat.pi / 8 && angle < 5 * CGFloat.pi / 8 {
            return .up
        } else if angle >= 5 * CGFloat.pi / 8 && angle < 7 * CGFloat.pi / 8 {
            return .upLeft
        } else if angle >= 7 * CGFloat.pi / 8 || angle < -7 * CGFloat.pi / 8 {
            return .left
        } else if angle >= -7 * CGFloat.pi / 8 && angle < -5 * CGFloat.pi / 8 {
            return .downLeft
        } else if angle >= -5 * CGFloat.pi / 8 && angle < -3 * CGFloat.pi / 8 {
            return .down
        } else if angle >= -3 * CGFloat.pi / 8 && angle < -CGFloat.pi / 8 {
            return .downRight
        }
        return .none
    }

}
