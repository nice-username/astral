//
//  AstralStageEditorPathInputHandler.swift
//  astral
//
//  Created by Joseph Haygood on 12/5/23.
//

import Foundation
import SpriteKit

class AstralStageEditorPathInputHandler {
    private var path : AstralStageEditorPath?
    private var currentNode : AstralPathNode?
    private var start: CGPoint?
    private var origin: CGPoint?
    private var manager: AstralStageEditorPathManager
    private var renderer: AstralStageEditorPathRenderer
    private var gameState: AstralGameStateManager
    private let pathSelectTouchThreshold: CGFloat = 25.0
    private var lastTapTime: TimeInterval = 0
    private var lastTapLocation: CGPoint?
    private weak var scene: AstralStageEditor?
    private var nodeTypeMenu = AstralStageEditorPathNodeTypeMenu(size: CGSize(width: 180.0, height: 100.0))
    


    init(scene: AstralStageEditor, pathManager: AstralStageEditorPathManager, pathRenderer: AstralStageEditorPathRenderer) {
        self.scene = scene
        self.manager = pathManager
        self.renderer = pathRenderer
        self.gameState = AstralGameStateManager.shared
    }

    
    private func updateLastTap(with currentTapTime: TimeInterval, location: CGPoint) {
        lastTapTime = currentTapTime
        lastTapLocation = location
    }
    
    
    
    func touchesBegan(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: scene!)

        let currentTapTime = touch.timestamp
        let doubleTapThreshold = 0.3

        
        // Begin placing node -- show type selection menu
        if self.gameState.editorState != .selectingNodeType &&
            self.gameState.editorState != .placingActionNode &&
            self.gameState.editorState != .placingCreationNode &&
            lastTapTime != 0 &&
            currentTapTime - lastTapTime < doubleTapThreshold,
           let lastTapLocation = lastTapLocation,
           lastTapLocation.distanceTo(touchLocation) < 25 {
            self.gameState.editorTransitionTo(.selectingNodeType)
            nodeTypeMenu.show(in: scene!, position: lastTapLocation)
        }
        
        // Finish placing node
        if gameState.editorState == .placingActionNode ||
            gameState.editorState == .placingCreationNode ||
            gameState.editorState == .placingPathingNode && 
            lastTapTime != 0 &&
            currentTapTime - lastTapTime < doubleTapThreshold,
            let lastTapLocation = lastTapLocation,
            lastTapLocation.distanceTo(touchLocation) < 25  {
            gameState.editorState = .idle
            
            if let node = currentNode {
                node.blink()
                self.setTestNodeData()
                let closestPoint = path!.closestPointOnPath(to: node.position)
                let closestSegment = path!.closestSegmentToPoint(closestPoint)
                closestSegment?.nodes.append(node)
                node.attachedToPath = path!
                if node is AstralPathNodeAction {
                    node.isActive = true
                }
            }
    
        }
        
        
        
        lastTapTime = currentTapTime
        lastTapLocation = touchLocation
        
        switch gameState.editorState {
            case .drawingNewPath:
                // Start a new path
                let newPathIndex = manager.addNewPath()
                path = manager.paths[newPathIndex]
                manager.setActivePath(index: newPathIndex)
                start = touch.location(in: scene!)
                origin = start
                path?.name = "Path \(newPathIndex + 1)"

            case .appendingToPath:
                // Continue drawing the current path
                // ...
                break

            case .editingNode, .editingBezier:
                // These states will have their own logic, which we'll define later
                break
            case .idle:
                break
            
            case .selectingPath:
                var closestPath: AstralStageEditorPath?
                var minDistance = pathSelectTouchThreshold
                for path in manager.paths {
                    let distance = path.distanceToClosestPoint(from: touchLocation)
                    if distance < minDistance {
                        minDistance = distance
                        closestPath = path
                    }
                }
                if let closestPath = closestPath {
                    // User has touched near a path
                    self.path = closestPath
                    self.manager.setActivePath(index: self.manager.getPathIndex(path: closestPath)!)
                    self.gameState.pathManager.loadPathData(path!)
                    renderer.updatePathColor(for: closestPath, color: .systemBlue)
                }
            
            case .placingCreationNode:
                self.attachNodeToClosestPath(to: touchLocation)
            
            default:
                break
        }
    }

    
    private func setTestNodeData() {
        if let node = currentNode as? AstralPathNodeCreation {
            node.initialTimeOffset = 0.0
            node.isEndless = false
            node.repeatEnabled = true
            node.repeatCount = 2
            node.repeatInterval = 0.5
        }
        if let node = currentNode as? AstralPathNodeAction {
            node.action = AstralEnemyOrder(type: .fire, duration: 1.0)
            node.name = "come on plz"
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: scene!)
        
        switch gameState.editorState {
        case .drawingNewPath, .appendingToPath:
            let pathStart = start ?? manager.lastSegmentEndPoint() ?? currentPoint
            let distance = pathStart.distanceTo(currentPoint)
            if distance > 10 {
                renderer.drawTemporaryLine(from: pathStart, to: currentPoint)
            }
            renderer.drawTemporaryLine(from: pathStart, to: currentPoint)
        case .placingCreationNode, .placingActionNode:
            self.attachNodeToClosestPath(to: currentPoint)
        default:
            break
        }
        
    }
    
    
    func attachNodeToClosestPath(to point: CGPoint) {
        if let node = currentNode, let pathIdx = manager.activePathIndex {
            let path = manager.paths[pathIdx]
            node.point = path.closestPointOnPath(to: point)
        }
    }
    
    
    func touchesEnded(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let closePathDistanceThreshold     = 40.0
        let createSegmentDistanceThreshold = 20.0
        
        switch gameState.editorState {
        case .drawingNewPath, .appendingToPath:
            let endPoint = touch.location(in: scene!)
            let pathStart = start ?? manager.lastSegmentEndPoint() ?? endPoint
            if let path = path {
                let distance = pathStart.distanceTo(endPoint)
                renderer.removeTemporaryLine()
                if distance > createSegmentDistanceThreshold {
                    if let origin = origin, endPoint.distanceTo(origin) < closePathDistanceThreshold {
                        // Snap to origin to close path
                        let segmentIndex = path.addSegment(type: .line(start: pathStart, end: origin))
                        gameState.editorState = .idle
                        // Here you can handle the logic for a completed path
                        let lastSegment = path.segments[segmentIndex]
                        renderer.drawDirectionIndicator(for: lastSegment)
                        renderer.drawPermanentLine(for: lastSegment)
                    } else {
                        // Add a new segment to the path
                        let segmentIndex = path.addSegment(type: .line(start: pathStart, end: endPoint))
                        start = endPoint
                        if gameState.editorState == .drawingNewPath {
                            gameState.editorState = .appendingToPath
                        }
                        let lastSegment = path.segments[segmentIndex]
                        renderer.drawDirectionIndicator(for: lastSegment)
                        renderer.drawPermanentLine(for: lastSegment)
                    }
                }
            }
            if gameState.editorState == .drawingNewPath {
                gameState.editorState = .appendingToPath
            }
        case .selectingPath:
            if let path = self.path {
                renderer.updatePathColor(for: path, color: .white)
            }
        case .idle:
            break
        case .editingNode:
            break
        case .editingBezier:
            break
            
        case .selectingNodeType:
            let touchPoint = touch.location(in: scene!)
            let touchedNodes = scene?.nodes(at: touchPoint)
            for node in touchedNodes! {
                if let nodeName = node.name {
                    switch nodeName {
                    case "nodeTypeCreationOption":
                        self.gameState.editorTransitionTo(.placingCreationNode)
                        let node = AstralPathNodeCreation(point: touchPoint)
                        currentNode = node
                        attachNodeToClosestPath(to: touchPoint)
                        scene!.addChild(node)
                        nodeTypeMenu.hide()
                        
                    case "nodeTypeActionOption":
                        self.gameState.editorTransitionTo(.placingActionNode)
                        let node = AstralPathNodeAction(point: touchPoint)
                        currentNode = node
                        attachNodeToClosestPath(to: touchPoint)
                        scene!.addChild(node)
                        nodeTypeMenu.hide()
                        
                    case "nodeTypePathingOption":
                        self.gameState.editorTransitionTo(.placingPathingNode)
                        nodeTypeMenu.hide()
                    default:
                        break
                    }
                    return
                }
            }
            // Close the menu
            if !touchedNodes!.contains(where: { $0.name == "nodeTypeMenuBackground" }) {
                nodeTypeMenu.hide()
                self.gameState.editorState = .idle
            }
            
        default:
            break
        }
    }
}
