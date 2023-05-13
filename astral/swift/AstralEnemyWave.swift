//
//  AstralEnemyWave.swift
//  astral
//
//  Created by Joseph Haygood on 5/12/23.
//

import Foundation
import SpriteKit

class AstralEnemyWave: SKNode {
    var enemyTypes: [AstralEnemy]       // Array of enemy types
    var spawnPositions: [CGPoint]       // Positions where each enemy will spawn
    var spawnTime: TimeInterval         // When this wave spawns
    var clearTime: TimeInterval         // How long the player has to clear this wave
    var polarities: [AstralPolarity]    // Array of polarities, one for each enemy type
    
    init(enemyTypes: [AstralEnemy], spawnPositions: [CGPoint], spawnTime: TimeInterval, clearTime: TimeInterval, polarities: [AstralPolarity]) {
        self.enemyTypes = enemyTypes
        self.spawnPositions = spawnPositions
        self.spawnTime = spawnTime
        self.clearTime = clearTime
        self.polarities = polarities
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnEnemies() -> [AstralEnemy] {
        // Make sure we have the same number of enemy types, positions, and polarities
        assert(enemyTypes.count == spawnPositions.count && enemyTypes.count == polarities.count)
        
        
        var enemies = [AstralEnemy]()
        /*
        for i in 0 ..< enemyTypes.count {
            let enemy = enemyTypes[i].clone() // You'll need to implement this method, or a similar one
            enemy.position = spawnPositions[i]
            enemy.polarity = polarities[i]
            enemies.append(enemy)
        }
         */
        return enemies
    }
}
