//
//  CameraShaker.swift
//  astral
//
//  Created by Joseph Haygood on 2/15/25.
//

import Foundation
import SpriteKit
import GameplayKit

class SKNodeShaker {
    private weak var node: SKNode?                  // Param
    private var shakeIntensity: CGFloat             // Param
    private var rotationIntensity: CGFloat          // Param
    private var decayRate: CGFloat                  // Param
    private var shakeDuration: TimeInterval         // Param
    private var elapsedTime: TimeInterval = 0.0     // Status
    private var isShaking = false                   // Status
    
    private var noiseSource: GKPerlinNoiseSource    // Thanks to Ken Perlin and Apple for this
    private var noise: GKNoise
    private var timePosition: CGFloat = 0.0         // Determines position of noise sample
    private var originalPosition: CGPoint = .zero   // These two are just for resetting
    private var originalRotation: CGFloat = 0       //
    
    init(node: SKNode?, intensity: CGFloat = 25.0, rotationIntensity: CGFloat = 0.08, duration: TimeInterval = 0.8, decay: CGFloat = 1.3) {
        self.node = node
        self.shakeIntensity = intensity
        self.rotationIntensity = rotationIntensity
        self.shakeDuration = duration
        self.decayRate = decay
        
        self.noiseSource = GKPerlinNoiseSource()
        noiseSource.frequency = 2.0
        noiseSource.octaveCount = 2
        noiseSource.persistence = 0.5
        self.noise = GKNoise(noiseSource)
        
        if let cam = node {
            self.originalPosition = cam.position
            self.originalRotation = cam.zRotation
        }
    }
    
    func startShake() {
        guard let node = node, !isShaking else { return }
        elapsedTime = 0
        isShaking = true
        originalPosition = node.position
        originalRotation = node.zRotation
        timePosition = CGFloat.random(in: 0...1000)
    }
    
    func update(deltaTime seconds: TimeInterval) {
        guard let node = node, isShaking else { return }
        
        elapsedTime += seconds
        
        // We're done shaking, stop and clean up.
        if elapsedTime >= shakeDuration {
            isShaking = false
            node.run(SKAction.move(to: originalPosition, duration: 0.1))
            node.run(SKAction.rotate(toAngle: originalRotation, duration: 0.1))
            return
        }
        
        let progress = elapsedTime / shakeDuration
        let damping = CGFloat(pow(1.0 - progress, Double(decayRate)))
        
        // I like to move it, move it
        let xNoise = noise.value(atPosition: vector_float2(Float(timePosition), 0))
        let yNoise = noise.value(atPosition: vector_float2(Float(timePosition + 100), 0))
        
        let offsetX = CGFloat(xNoise) * shakeIntensity * damping
        let offsetY = CGFloat(yNoise) * shakeIntensity * damping
        
        // Rotation shake is sampled at a different position to make movement more unique
        let rotationNoise = noise.value(atPosition: vector_float2(Float(timePosition + 200), 0))
        let rotationOffset = CGFloat(rotationNoise) * rotationIntensity * damping
        
        node.position = CGPoint(
            x: originalPosition.x + offsetX,
            y: originalPosition.y + offsetY
        )
        node.zRotation = originalRotation + rotationOffset
        
        timePosition += CGFloat(seconds) * 4.0
    }
}
