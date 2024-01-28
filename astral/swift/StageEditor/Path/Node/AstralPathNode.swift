//
//  AstralPathNode.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation
import SpriteKit



enum AstralGameObjectType: Int, Codable {
    case enemy
    case powerup
    case object
}


struct AstralPathNodeData: Codable {
    struct ShapePropertiesData: Codable {
        var name: String?
        var width: CGFloat
        var height: CGFloat
        var position: CGPoint
        var zPosition: CGFloat
        var fillColor: UIColorData
        var strokeColor: UIColorData
        var lineWidth: CGFloat
    }
    
    var point: CGPoint
    var isActive: Bool
    var timeSinceActivation: TimeInterval
    var shapeProperties: ShapePropertiesData
    
    init(from node: AstralPathNode) {
        self.point = node.position
        self.isActive = node.isActive
        self.timeSinceActivation = node.timeSinceActivation

        // Extract and convert shape properties
        self.shapeProperties = ShapePropertiesData(
            name: node.name,
            width: node.frame.width,
            height: node.frame.height,
            position: node.position,
            zPosition: node.zPosition,
            fillColor: node.fillColor.toData(),
            strokeColor: node.strokeColor.toData(),
            lineWidth: node.lineWidth
        )
    }

}


struct AstralPathNodeActionData: Codable {
    var baseNodeData: AstralPathNodeData
    var action: AstralEnemyOrder?
    var triggeredByEnemies: [UUID] // Sets are not directly Codable, so we use an Array

    init(from node: AstralPathNodeAction) {
        self.baseNodeData = node.toData()
        self.action = node.action
        self.triggeredByEnemies = Array(node.triggeredByEnemies)
    }
    
    // Method to create an AstralPathNodeAction from AstralPathNodeActionData
    func toNode() -> AstralPathNodeAction {
        let node = AstralPathNodeAction(from: baseNodeData)
        node.action = self.action
        node.triggeredByEnemies = Set(self.triggeredByEnemies)
        return node
    }
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
    
    convenience init(from data: AstralPathNodeData) {
        self.init(point: data.point)
        self.isActive = data.isActive
        self.timeSinceActivation = data.timeSinceActivation
        
        // Set up the shape node properties
        self.position = data.shapeProperties.position
        self.fillColor = UIColor(from: data.shapeProperties.fillColor)
        self.strokeColor = UIColor(from: data.shapeProperties.strokeColor)
        self.lineWidth = data.shapeProperties.lineWidth
        
        // TODO: Attach to the path by the pathName
    }
    
    
    func blink() {
        let originalColor = self.fillColor
        let whiteBlink = SKAction.customAction(withDuration: 0.0125) { node, _ in
            if let shapeNode = node as? SKShapeNode {
                shapeNode.fillColor = .white
            }
        }
        let originalColorBlink = SKAction.customAction(withDuration: 0.0125) { node, _ in
            if let shapeNode = node as? SKShapeNode {
                shapeNode.fillColor = originalColor
            }
        }
        let waitAction = SKAction.wait(forDuration: 0.05)
        let blinkSequence = SKAction.sequence([whiteBlink, waitAction, originalColorBlink, waitAction])
        let blinkTwiceAction = SKAction.repeat(blinkSequence, count: 3)

        self.run(blinkTwiceAction)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isPoint(_ point: CGPoint, withinDistance distance: CGFloat) -> Bool {
        let nodePosition = self.position
        return point.distanceTo(nodePosition) <= distance
    }
    
    func toData() -> AstralPathNodeData {
        return AstralPathNodeData(from: self)
    }
}



class AstralPathNodeAction: AstralPathNode {
    var action: AstralEnemyOrder?
    var triggeredByEnemies = Set<UUID>()
    
    override init(point: CGPoint) {
        super.init(point: point)
        self.fillColor = UIColor(red:   224 / 255.0,
                                 green: 16  / 255.0,
                                 blue:  24  / 255.0,
                                 alpha: 255 / 255.0)
    }
    
    convenience init(from: AstralPathNodeActionData) {
        self.init(point: from.baseNodeData.point)
    }
    
    func performAction(for enemy: AstralEnemy) {
        guard let action = action else {
            print("No action defined for this node.")
            return
        }

        // Check if this enemy has already triggered the action
        if triggeredByEnemies.contains(enemy.id) {
            return // The action has already been performed for this enemy
        }
        
        // Perform the action here
        switch action.type {
        case .turnRight(let duration, let angle), .turnLeft(let duration, let angle):
            enemy.turn(direction: action.type, duration: duration, angle: angle)
            
        case .fire:
            enemy.isShooting = true
            
        case .fireStop:
            enemy.isShooting = false
            break
            
        default:
            break
        }

        // Mark this node as triggered by the current enemy
        triggeredByEnemies.insert(enemy.id)
    }

    // Call this method when you want to reset the node, for example, when a new level starts
    func reset() {
        triggeredByEnemies.removeAll()
    }
    
    func isTriggered(by enemy: AstralEnemy) -> Bool {
        return triggeredByEnemies.contains(enemy.id)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



struct AstralPathNodeCreationData: Codable {
    var baseNodeData: AstralPathNodeData
    var timeSinceLastCreation: TimeInterval
    var objectType: AstralGameObjectType
    var objectIndex: Int
    var repeatEnabled: Bool
    var repeatCount: Int
    var repeatInterval: TimeInterval
    var isEndless: Bool
    var initialTimeOffset: TimeInterval
    var initialSpeed: CGFloat

    init(from node: AstralPathNodeCreation) {
        self.baseNodeData = node.toData()
        self.timeSinceLastCreation = node.timeSinceLastCreation
        self.objectType = node.objectType
        self.objectIndex = node.objectIndex
        self.repeatEnabled = node.repeatEnabled
        self.repeatCount = node.repeatCount
        self.repeatInterval = node.repeatInterval
        self.isEndless = node.isEndless
        self.initialTimeOffset = node.initialTimeOffset
        self.initialSpeed = node.initialSpeed
    }

    // Method to create an AstralPathNodeCreation from AstralPathNodeCreationData
    func toNode() -> AstralPathNodeCreation {
        let node = AstralPathNodeCreation(from: baseNodeData)
        node.timeSinceLastCreation = self.timeSinceLastCreation
        node.objectType = self.objectType
        node.objectIndex = self.objectIndex
        node.repeatEnabled = self.repeatEnabled
        node.repeatCount = self.repeatCount
        node.repeatInterval = self.repeatInterval
        node.isEndless = self.isEndless
        node.initialTimeOffset = self.initialTimeOffset
        node.initialSpeed = self.initialSpeed
        return node
    }
}



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
