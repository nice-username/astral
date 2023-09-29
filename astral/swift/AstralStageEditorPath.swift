//
//  AstralStageEditorPath.swift
//  astral
//
//  Created by Joseph Haygood on 9/26/23.
//

import Foundation
import UIKit



class AstralPathNode {
    var point: CGPoint
    var order: AstralEnemyOrder
    
    init(point: CGPoint, order: AstralEnemyOrder) {
        self.point = point
        self.order = order
    }
}

enum AstralPathSegmentType {
    case line(start: CGPoint, end: CGPoint)
    case bezier(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint)
}


class AstralPathSegment {
    var type: AstralPathSegmentType
    var nodes: [AstralPathNode] = []
    
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
}


class AstralStageEditorPath {
    var segments: [AstralPathSegment] = []
    
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
}
