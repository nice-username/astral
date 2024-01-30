//
//  AstralPathNodeData.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/24.
//

import Foundation
import UIKit

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
    
    func toNode() -> AstralPathNode {
        let node = AstralPathNode(point: self.point)
        node.isActive = self.isActive
        node.timeSinceActivation = self.timeSinceActivation

        // Apply the shape properties
        node.name = self.shapeProperties.name
        node.position = self.shapeProperties.position
        node.zPosition = self.shapeProperties.zPosition
        node.fillColor = UIColor(from: self.shapeProperties.fillColor)
        node.strokeColor = UIColor(from: self.shapeProperties.strokeColor)
        node.lineWidth = self.shapeProperties.lineWidth

        // Set node size if needed, might depend on how your SKShapeNode is structured
        node.path = CGPath(ellipseIn: CGRect(x: -self.shapeProperties.width / 2,
                                             y: -self.shapeProperties.height / 2,
                                             width: self.shapeProperties.width,
                                             height: self.shapeProperties.height), transform: nil)

        return node
    }
}
