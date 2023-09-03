//
//  AstralStageEditorAction.swift
//  astral
//
//  Created by Joseph Haygood on 7/31/23.
//

import Foundation

enum AstralStageEditorAction {
    case stageMenu
    case transitionMenu
    case pathMenu
    case enemyMenu
    case testMenu
    
    case stageCreate
    case stageRename
    case stageSave
    case stageLoad
    case stageExit
    case stageLength
    case stageBackground
    
    case transitionLocation
    case transitionArt
    case transitionAnimation
    
    case pathCreate
    case pathExtend
    case pathTrim
    case pathRemove
    case pathMove
    case pathAdjustShape
    case pathAddNode
    case pathRemoveNode
    case pathEditNodeAction
    
    case enemySelectType
    case enemyTypeProperties
    case enemyAddToPath
    case enemyDelete
}
