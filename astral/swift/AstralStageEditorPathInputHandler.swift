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
    private var start: CGPoint?
    private var origin: CGPoint?
    private var manager: AstralStageEditorPathManager
    private var renderer: AstralStageEditorPathRenderer
    private var editorState: AstralStageEditorState

    init(pathManager: AstralStageEditorPathManager, pathRenderer: AstralStageEditorPathRenderer, editorState: AstralStageEditorState) {
        self.manager = pathManager
        self.renderer = pathRenderer
        self.editorState = editorState
    }

    func touchesBegan(_ touches: Set<UITouch>, in scene: SKScene) {
        guard let touch = touches.first else { return }
    
        switch editorState {
            case .idle:
                // Start a new path
                let newPathIndex = manager.addNewPath()
                path = manager.paths[newPathIndex]
                manager.setActivePath(index: newPathIndex)
                start = touch.location(in: scene)
                origin = start
                editorState = .drawingNewPath

            case .drawingNewPath, .appendingToPath:
                // Continue drawing the current path
                // ...
                break

            case .editingNode, .editingBezier:
                // These states will have their own logic, which we'll define later
                break
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, in scene: SKScene) {
        guard let touch = touches.first, editorState == .drawingNewPath || editorState == .appendingToPath else { return }
        
        switch editorState {
        case .drawingNewPath, .appendingToPath:
            let currentPoint = touch.location(in: scene)
            let pathStart = start ?? manager.lastSegmentEndPoint() ?? currentPoint
            let distance = pathStart.distanceTo(currentPoint)
            if distance > 10 { // TODO: Replace 10 with a variable for the minimum distance
                renderer.drawTemporaryLine(from: pathStart, to: currentPoint)
            }
            renderer.drawTemporaryLine(from: pathStart, to: currentPoint)
            
        default:
            break
        }
        
    }

    func touchesEnded(_ touches: Set<UITouch>, in scene: SKScene) {
        guard let touch = touches.first, editorState == .drawingNewPath || editorState == .appendingToPath else { return }
        
        let closePathDistanceThreshold     = 40.0
        let createSegmentDistanceThreshold = 20.0
    
        switch editorState {
        case .drawingNewPath, .appendingToPath:
            let endPoint = touch.location(in: scene)
            let pathStart = start ?? manager.lastSegmentEndPoint() ?? endPoint
            if let path = path {
                let distance = pathStart.distanceTo(endPoint)
                renderer.removeTemporaryLine()
                if distance > createSegmentDistanceThreshold {
                    if let origin = origin, endPoint.distanceTo(origin) < closePathDistanceThreshold {
                        // Snap to origin to close path
                        let segmentIndex = path.addSegment(type: .line(start: pathStart, end: origin))
                        editorState = .idle
                        // Here you can handle the logic for a completed path
                        let lastSegment = path.segments[segmentIndex]
                        renderer.drawDirectionIndicator(for: lastSegment)
                        renderer.drawPermanentLine(for: lastSegment)
                    } else {
                        // Add a new segment to the path
                        let segmentIndex = path.addSegment(type: .line(start: pathStart, end: endPoint))
                        start = endPoint
                        if editorState == .drawingNewPath {
                            editorState = .appendingToPath
                        }
                        let lastSegment = path.segments[segmentIndex]
                        renderer.drawDirectionIndicator(for: lastSegment)
                        renderer.drawPermanentLine(for: lastSegment)
                    }
                }
            }
        case .idle:
            break
        case .editingNode:
            break
        case .editingBezier:
            break
        }
    }
}
