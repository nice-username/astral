//
//  AstralPathNode.swift
//  astral
//
//  Created by Joseph Haygood on 12/15/23.
//

import Foundation
import SpriteKit





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
        self.fillColor = .white
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
