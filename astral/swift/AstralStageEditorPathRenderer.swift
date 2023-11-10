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
        temporaryLineShape!.strokeColor = .systemBlue
        temporaryLineShape!.lineCap = .round
        temporaryLineShape!.zPosition = 4
        
        scene?.addChild(temporaryLineShape!)
    }
    
    // Creates the arrow shape for the direction indicator
    func createArrowShape(withAngle angle: CGFloat) -> SKShapeNode {
        let arrowPath = UIBezierPath()
        let arrowLength: CGFloat = 20
        let arrowWidth: CGFloat = 30

        arrowPath.move(to: CGPoint(x: -arrowLength / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowLength / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: arrowWidth))
        arrowPath.close()

        let arrowShape = SKShapeNode(path: arrowPath.cgPath)
        arrowShape.zRotation = angle
        arrowShape.lineWidth = 1.5
        arrowShape.strokeColor = .white
        arrowShape.fillColor = .white
        arrowShape.zPosition = 5
        
        return arrowShape
    }
    
    // Calculates the animation points for the arrow's movement
    func calculateArrowAnimationPoints(for segment: AstralPathSegment, withOffset offset: CGFloat) -> (startPoint: CGPoint, endPoint: CGPoint) {
        let startPoint = segment.startPoint()
        let endPoint = segment.endPoint()
        let pathVector = CGVector(dx: endPoint.x - startPoint.x, dy: endPoint.y - startPoint.y)
        let pathLength = sqrt(pathVector.dx * pathVector.dx + pathVector.dy * pathVector.dy)
        let normalizedVector = CGVector(dx: pathVector.dx / pathLength, dy: pathVector.dy / pathLength)
        let animationStartPoint = CGPoint(x: startPoint.x + normalizedVector.dx * offset, y: startPoint.y + normalizedVector.dy * offset)
        let animationEndPoint = CGPoint(x: endPoint.x - normalizedVector.dx * offset, y: endPoint.y - normalizedVector.dy * offset)

        return (animationStartPoint, animationEndPoint)
    }
    
    func createArrowAnimation(startPoint: CGPoint, endPoint: CGPoint) -> SKAction {
        let fadeInDuration = 0.3333
        let moveDuration = 1.6667
        let fadeOutDuration = 0.3333
        let fadeOutStart = moveDuration - fadeOutDuration

        let fadeIn = SKAction.fadeIn(withDuration: fadeInDuration)
        let moveForward = SKAction.move(to: endPoint, duration: moveDuration)
        let fadeOut = SKAction.fadeOut(withDuration: fadeOutDuration)
        let delayForFadeOut = SKAction.wait(forDuration: fadeOutStart)
        let moveAndFadeOut = SKAction.sequence([delayForFadeOut, fadeOut])
        let moveWhileVisible = SKAction.group([fadeIn, moveForward, moveAndFadeOut])
        let fadeMoveAndFade = SKAction.sequence([moveWhileVisible, SKAction.move(to: startPoint, duration: 0)])
        let repeatAction = SKAction.repeatForever(fadeMoveAndFade)

        return repeatAction
    }

    // The refactored drawDirectionIndicator function
    func drawDirectionIndicator(for segment: AstralPathSegment) {
        guard let scene = scene else { return }
        
        let (_, angle) = segment.midPointAndAngle()
        let arrowShape = createArrowShape(withAngle: angle)
        segment.directionArrow = arrowShape
        scene.addChild(arrowShape)

        let (animationStartPoint, animationEndPoint) = calculateArrowAnimationPoints(for: segment, withOffset: 40.0)
        arrowShape.position = animationStartPoint
        let arrowAnimation = createArrowAnimation(startPoint: animationStartPoint, endPoint: animationEndPoint)
        arrowShape.run(arrowAnimation)
    }

    
    func removeTemporaryLine() {
        temporaryLineShape?.removeFromParent()
    }
    
    func drawPermanentLine(for segment: AstralPathSegment) {
        // Remove old shape if it exists
        segment.shape?.removeFromParent()

        // Create a new shape for the segment
        let shape = SKShapeNode()
        let path = UIBezierPath()
        switch segment.type {
        case .line(let start, let end):
            path.move(to: start)
            path.addLine(to: end)
        case .bezier(let start, let control1, let control2, let end):
            path.move(to: start)
            path.addCurve(to: end, controlPoint1: control1, controlPoint2: control2)
        }
        shape.path = path.cgPath
        shape.lineWidth = 8
        shape.strokeColor = .white
        shape.lineCap = .round
        shape.zPosition = 4
        shape.alpha = 0.75

        // Update the segment's shape reference
        segment.shape = shape

        // Add the new permanent line
        scene?.addChild(shape)
    }
}
