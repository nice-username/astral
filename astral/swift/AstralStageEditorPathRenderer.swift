//
//  AstralStageEditorPathRenderer.swift
//  astral
//
//  Created by Joseph Haygood on 9/29/23.
//

import Foundation
import SpriteKit

class AstralPathRenderer {
    weak var scene: SKScene? // Weak to prevent retain cycle
    var temporaryLineShape: SKShapeNode?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func drawTemporaryLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        temporaryLineShape?.removeFromParent() // Remove the previous temporary line
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        temporaryLineShape = SKShapeNode(path: path.cgPath)
        temporaryLineShape!.lineWidth = 8
        temporaryLineShape!.strokeColor = .white
        temporaryLineShape!.lineCap = .round
        temporaryLineShape!.zPosition = 4
        
        scene?.addChild(temporaryLineShape!)
    }
    
    func removeTemporaryLine() {
        temporaryLineShape?.removeFromParent()
    }
    
    func drawPermanentLines(from stageEditorPath: AstralStageEditorPath) {
        let path = stageEditorPath.toUIBezierPath()
        let shape = SKShapeNode(path: path.cgPath)
        shape.lineWidth = 8
        shape.strokeColor = .white
        shape.lineCap = .round
        shape.zPosition = 4
        
        // Add the new permanent lines
        scene?.addChild(shape)
    }
}
