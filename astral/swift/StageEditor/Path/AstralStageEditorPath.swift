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


class AstralPathSegment : SKNode {
    var type: AstralPathSegmentType
    var shape: SKShapeNode?
    var nodes: [AstralPathNode] = []
    var directionArrow: SKShapeNode?
    
    init(type: AstralPathSegmentType) {
        self.type = type
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Adds a node and returns its index
    func addNode(at point: CGPoint) -> Int {
        let node = AstralPathNode(point: point)
        nodes.append(node)
        return nodes.count - 1
    }
    
    // Removes a node by index
    func removeNode(at index: Int) {
        nodes.remove(at: index)
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
    
    func closestPointOnLineSegment(point: CGPoint) -> CGPoint {
        let start = self.startPoint()
        let end = self.endPoint()
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx*dx + dy*dy
        var t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared
        t = max(0, min(1, t)) // Clamp t to the range [0, 1]
        return CGPoint(x: start.x + t * dx, y: start.y + t * dy)
    }
}


class AstralStageEditorPath: SKNode {
    var segments: [AstralPathSegment] = []
    var direction: AstralPathDirection = .forwards
    var activationProgress: Float = 0.0
    var deactivationProgress: Float = 100.0
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
    
    func findClosestNode(to point: CGPoint, in path: AstralStageEditorPath) -> AstralPathNode? {
        var closestNode: AstralPathNode?
        var minimumDistance = CGFloat.greatestFiniteMagnitude
        for segment in path.segments {
            for node in segment.nodes {
                let distance = node.point.distanceTo(point)
                if distance < minimumDistance {
                    minimumDistance = distance
                    closestNode = node
                }
            }
        }
        return closestNode
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
        for segment in segments {
            if shouldShow {
                segment.fadeIn(duration: 0.25)
            } else {
                segment.fadeOut(duration: 0.25)
            }
        }
    }
    
    func closestPointOnPath(to point: CGPoint) -> CGPoint {
        var closestPoint = CGPoint.zero
        var minDistance = CGFloat.greatestFiniteMagnitude
        var segmentClosestPoint: CGPoint

        for segment in segments {
            segmentClosestPoint = segment.closestPointOnLineSegment(point: point)
            // For now we are ignore bezier curved line segments.
            let distance = segmentClosestPoint.distanceTo(point)
            if distance < minDistance {
                minDistance = distance
                closestPoint = segmentClosestPoint
            }
        }
        return closestPoint
    }
    
    func activate(currentTime: TimeInterval) {
        self.isActivated = true
        for segment in self.segments {
            for node in segment.nodes {
                if let creationNode = node as? AstralPathNodeCreation {
                    creationNode.startCreationLoop(currentTime: currentTime)
                }
                if let actionNode = node as? AstralPathNodeAction {
                    node.isActive = true
                }
            }
        }
    }
    
    func closestSegmentToPoint(_ point: CGPoint) -> AstralPathSegment? {
        var closestSegment: AstralPathSegment?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for segment in self.segments {
            var distance: CGFloat

            switch segment.type {
            case .line(let start, let end):
                distance = point.distanceToLineSegment(start: start, end: end)
            case .bezier(let start, let control1, let control2, let end):
                // For bezier segments, you need a more complex calculation
                // Placeholder: use distance to start and end points of the bezier segment
                let distanceToStart = point.distanceTo(start)
                let distanceToEnd = point.distanceTo(end)
                distance = min(distanceToStart, distanceToEnd)
            }

            if distance < minDistance {
                minDistance = distance
                closestSegment = segment
            }
        }

        return closestSegment
    }

}
