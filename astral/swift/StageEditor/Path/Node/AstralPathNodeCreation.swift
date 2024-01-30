//
//  AstralPathNodeCreation.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/24.
//

import Foundation
import UIKit

class AstralPathNodeCreation: AstralPathNode {
    var timeSinceLastCreation: TimeInterval         = 0.0
    var objectType:            AstralGameObjectType = .enemy
    var objectIndex:           Int                  = 1
    var repeatEnabled:         Bool                 = false
    var repeatCount:           Int                  = 0
    var repeatInterval:        TimeInterval         = 0
    var isEndless:             Bool                 = false
    var initialTimeOffset:     TimeInterval         = 0.0
    var initialSpeed:          CGFloat              = 100.0
    private var didFirstCreation: Bool = true

    
    override init(point: CGPoint) {
        super.init(point: point)
        self.fillColor = UIColor(red:   32  / 255.0,
                                 green: 224 / 255.0,
                                 blue:  16  / 255.0,
                                 alpha: 255 / 255.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(from data: AstralPathNodeCreationData) {
        self.init(from: data.baseNodeData)
        self.timeSinceLastCreation = data.timeSinceLastCreation
        self.objectType = data.objectType
        self.objectIndex = data.objectIndex
        self.repeatEnabled = data.repeatEnabled
        self.repeatCount = data.repeatCount
        self.repeatInterval = data.repeatInterval
        self.isEndless = data.isEndless
        self.initialTimeOffset = data.initialTimeOffset
        self.initialSpeed = data.initialSpeed
    }
    
    func toData() -> AstralPathNodeCreationData {
        return AstralPathNodeCreationData(from: self)
    }
       
    func startCreationLoop(currentTime: TimeInterval) {
        self.isActive = true
        self.timeSinceActivation = 0.0
        self.timeSinceLastCreation = 0.0
        self.didFirstCreation = false
    }

    func repeatAction(deltaTime: TimeInterval) {
        guard isActive && repeatEnabled else { return }
        
        timeSinceActivation += deltaTime
        timeSinceLastCreation += deltaTime
        
        let shouldCreateNow = didFirstCreation ?
                              (timeSinceLastCreation >= repeatInterval) :
                              (timeSinceLastCreation >= initialTimeOffset)

        if shouldCreateNow {
            let unit = createEntity()
            if let enemy = unit as? AstralEnemy {
                enemy.position = self.position
                enemy.movementSpeed = initialSpeed
                enemy.followPath(self.attachedToPath!)
                (self.scene as? AstralStageEditor)?.enemies.append(enemy)
            }
            timeSinceLastCreation = 0.0
            didFirstCreation = true

            // Handle repeat count and endless flag
            if !isEndless {
                repeatCount -= 1
                if repeatCount <= 0 {
                    isActive = false
                }
            }
        }
    }
    
    private func createEntity() -> AstralUnit {
        // Depending on the objectType and objectIndex, we will fetch the appropriate configuration
        // For this example, let's assume objectType is .enemy and objectIndex corresponds to a key in the global configuration
        switch objectType {
        case .enemy:
            if let config = AstralGlobalEnemyConfiguration["enemy\(objectIndex)"] {
                let enemy = AstralEnemy(scene: self.scene!, config: config)
                enemy.zPosition = 4
                return enemy
            }
        case .powerup:
            break
        case .object:
            break
        }
        fatalError("Configuration for object type '\(objectType)' and index '\(objectIndex)' not found.")
    }
}
