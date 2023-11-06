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
    
    func drawDirectionIndicator(for segment: AstralPathSegment) {
        guard let scene = scene else { return }
        
        // Calculate the midpoint and angle of the segment
        let (_, angle) = segment.midPointAndAngle()

        // Create a path for the arrow shape
        let arrowPath = UIBezierPath()
        let arrowLength: CGFloat = 20  // The length of the arrow
        let arrowWidth: CGFloat = 30   // The width of the arrow base

        arrowPath.move(to: CGPoint(x: -arrowLength / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowLength / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: 0, y: arrowWidth))
        arrowPath.close()

        // Create the shape node
        let arrowShape = SKShapeNode(path: arrowPath.cgPath)
        segment.directionArrow = arrowShape
        arrowShape.zRotation = angle
        arrowShape.lineWidth = 1.5
        arrowShape.strokeColor = SKColor.white
        arrowShape.fillColor = SKColor.white
        arrowShape.zPosition = 5  // Ensure it's above the path line
        
        // Add the arrow to the scene
        scene.addChild(arrowShape)
    
        // Calculate start and end points for the arrow's animation
        let arrowPositionOffset = 40.0
        let startPoint = segment.startPoint()
        let endPoint = segment.endPoint()
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let pathVector = CGVector(dx: dx, dy: dy)
        let pathLength = sqrt(pathVector.dx * pathVector.dx + pathVector.dy * pathVector.dy)
        let normalizedVector = CGVector(dx: pathVector.dx / pathLength, dy: pathVector.dy / pathLength)
        let animationStartPoint = CGPoint(x: startPoint.x + normalizedVector.dx * arrowPositionOffset, y: startPoint.y + normalizedVector.dy * arrowPositionOffset)
        let animationEndPoint = CGPoint(x: endPoint.x - normalizedVector.dx * arrowPositionOffset,
                                        y: endPoint.y - normalizedVector.dy * arrowPositionOffset)
        arrowShape.position = animationStartPoint
        
        // Define the duration for each part of the animation
        let fadeInDuration = 0.3333
        let moveDuration = 1.6667 // Total duration for the movement
        let fadeOutDuration = 0.3333

        // Calculate the time to start fading out so it completes just as the movement ends
        let fadeOutStart = moveDuration - fadeOutDuration

        // Create the fade and move actions
        let fadeIn = SKAction.fadeIn(withDuration: fadeInDuration)
        let moveForward = SKAction.move(to: animationEndPoint, duration: moveDuration)
        let fadeOut = SKAction.fadeOut(withDuration: fadeOutDuration)

        // Create a delay action for the fade-out to start later in the sequence
        let delayForFadeOut = SKAction.wait(forDuration: fadeOutStart)

        // Combine the move and fade out actions into a sequence
        let moveAndFadeOut = SKAction.sequence([delayForFadeOut, fadeOut])

        // Create a group so the arrow stays fully visible while moving, before fading out
        let moveWhileVisible = SKAction.group([fadeIn, moveForward, moveAndFadeOut])

        // Combine all actions into a sequence
        let fadeMoveAndFade = SKAction.sequence([moveWhileVisible, SKAction.move(to: animationStartPoint, duration: 0)])

        // Repeat the sequence forever
        let repeatAction = SKAction.repeatForever(fadeMoveAndFade)

        // Run the action on the arrow node
        arrowShape.run(repeatAction)
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
        shape.alpha = 0.75
        
        // Add the new permanent lines
        scene?.addChild(shape)
    }
}
