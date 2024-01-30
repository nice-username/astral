//
//  AstralPathNodeActionData.swift
//  astral
//
//  Created by Joseph Haygood on 1/28/24.
//

import Foundation


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
