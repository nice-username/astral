//
//  AstralPathNode.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation
import SpriteKit



enum AstralGameObjectType {
    case enemy
    case powerup
    case object
}



class AstralPathNode: SKShapeNode, AstralPathNodeProtocol {
    var point: CGPoint {
        didSet {
            self.position = point
        }
    }
    var attachedToPath: AstralStageEditorPath?
    var conditions: [AstralPathNodeCondition] = []
    var isActive: Bool = false
    var timeSinceActivation: TimeInterval = 0.0

    init(point: CGPoint) {
        self.point = point
        self.conditions.append(DefaultCondition())
        super.init()

        // Initialize the SKShapeNode properties
        self.path = CGPath(ellipseIn: CGRect(x: -16, y: -16, width: 32, height: 32), transform: nil)
        self.zPosition = 10
        self.lineWidth = 6
        self.fillColor = .red
        self.strokeColor = .white
        self.position = point
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AstralPathNodeAction: AstralPathNode {}

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
                enemy.followPath(self.attachedToPath!)
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
