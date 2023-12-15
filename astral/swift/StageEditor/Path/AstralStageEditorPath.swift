//
//  AstralStageEditorPath.swift
//  astral
//
//  Created by Joseph Haygood on 9/26/23.
//

import Foundation
import UIKit
import SpriteKit



enum AstralPathDirection {
    case forwards
    case backwards
}

enum AstralPathEndBehavior {
    case loop
    case reverse
    case stop
}

enum AstralPathSegmentType {
    case line(start: CGPoint, end: CGPoint)
    case bezier(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint)
}


class AstralPathSegment {
    var type: AstralPathSegmentType
    var shape: SKShapeNode?
    var nodes: [AstralPathNode] = []
    var directionArrow: SKShapeNode?
    
    init(type: AstralPathSegmentType) {
        self.type = type
    }
    
    // Adds a node and returns its index
    func addNode(at point: CGPoint, order: AstralEnemyOrder) -> Int {
        let node = AstralPathNode(point: point, order: order)
        nodes.append(node)
        return nodes.count - 1
    }
    
    // Removes a node by index
    func removeNode(at index: Int) {
        nodes.remove(at: index)
    }
    
    // Update existing node
    func updateNode(at index: Int, with point: CGPoint, order: AstralEnemyOrder) {
        nodes[index].point = point
        nodes[index].order = order
    }
    
    // get the center and facing angle of the segment for drawing arrows
    func midPointAndAngle() -> (CGPoint, CGFloat) {
        switch type {
        case .line(let start, let end):
            let midPoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
            let angle = atan2(end.y - start.y, end.x - start.x)
            let adjustedAngle = angle - (CGFloat.pi / 2)
            return (midPoint, adjustedAngle)
        case .bezier(let start, _, _, let end):
            // For Bezier segments, this will only be approximate
            let midPoint = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
            let angle = atan2(end.y - start.y, end.x - start.x)
            let adjustedAngle = angle - (CGFloat.pi / 2)
            return (midPoint, adjustedAngle)
        }
    }
    
    // Helper function to get the start point of the segment
    func startPoint() -> CGPoint {
        switch type {
        case .line(let start, _), .bezier(let start, _, _, _):
            return start
        }
    }

    // Helper function to get the end point of the segment
    func endPoint() -> CGPoint {
        switch type {
        case .line(_, let end), .bezier(_, _, _, let end):
            return end
        }
    }
    func animateDeletion(completion: @escaping () -> Void) {
        let fadeOutAction = SKAction.fadeOut(withDuration: 1 / 8.0)
        let waitAction = SKAction.wait(forDuration: 1 / 30.0) // This is the delay before starting the next deletion
        let removeAction = SKAction.removeFromParent()

        if let shapeNode = self.shape {
            self.directionArrow!.removeFromParent()
            shapeNode.strokeColor = .red
            let sequence = SKAction.sequence([fadeOutAction, removeAction])

            // Start the sequence, but call completion after the shorter wait period
            shapeNode.run(sequence)
            shapeNode.run(waitAction) {
                completion()
            }
        }
    }
    
    func fadeIn(duration: TimeInterval) {
        if let shapeNode = self.shape {
            NotificationCenter.default.post(name: .pathAddToScene, object: nil, userInfo: ["segment": self])
            let fade = SKAction.fadeIn(withDuration: duration)
            shapeNode.run( fade , withKey: "show/hide")
            directionArrow!.run( fade, withKey: "show/hide")
        }
    }

    func fadeOut(duration: TimeInterval) {
        if let shapeNode = self.shape {
            let fade = SKAction.fadeOut(withDuration: duration)
            let remove = SKAction.removeFromParent()
            shapeNode.run( SKAction.sequence([fade, remove]), withKey: "show/hide" )
            directionArrow!.run( SKAction.sequence([fade, remove]), withKey: "show/hide")
        }
    }
}


class AstralStageEditorPath {
    var name: String = ""
    var segments: [AstralPathSegment] = []
    var direction: AstralPathDirection = .forwards
    var activationProgress: Float = 0.0
    var deactivationProgress: Float = 0.0
    var endBehavior: AstralPathEndBehavior = .loop
    var isActivated: Bool = true
    
    // Adds a segment and returns its index
    func addSegment(type: AstralPathSegmentType) -> Int {
        let segment = AstralPathSegment(type: type)
        segments.append(segment)
        return self.segments.count - 1
    }
    
    // Removes a segment by index
    func removeSegment(at index: Int) {
        self.segments.remove(at: index)
    }
    
    // Update existing segment
    func updateSegment(at index: Int, with type: AstralPathSegmentType) {
        self.segments[index].type = type
    }
    
    // Convert all segments to a UIKit path for drawing
    func toUIBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        for segment in segments {
            switch segment.type {
            case .line(let start, let end):
                path.move(to: start)
                path.addLine(to: end)
            case .bezier(let start, let control1, let control2, let end):
                path.move(to: start)
                path.addCurve(to: end, controlPoint1: control1, controlPoint2: control2)
            }
        }
        return path
    }
    
    func distanceToClosestPoint(from point: CGPoint) -> CGFloat {
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        for segment in segments {
            switch segment.type {
            case .line(let start, let end):
                let distance = point.distanceToLineSegment(start: start, end: end)
                closestDistance = min(closestDistance, distance)
            case .bezier(let start, let control1, let control2, let end):
                // For bezier, you might need a more complex calculation
                // As a placeholder, we use the start and end points
                let distanceToStart = point.distanceTo(start)
                let distanceToEnd = point.distanceTo(end)
                closestDistance = min(closestDistance, distanceToStart, distanceToEnd)
            }
        }
        return closestDistance
    }
    
    func toggleVisibility(shouldShow: Bool) {
        isActivated = shouldShow
        for segment in segments {
            if shouldShow {
                segment.fadeIn(duration: 0.25)
            } else {
                segment.fadeOut(duration: 0.25)
            }
        }
    }
}
