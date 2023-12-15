//
//  AstralStageEditorPathManager.swift
//  astral
//
//  Created by Joseph Haygood on 10/31/23.
//

import Foundation



class AstralStageEditorPathManager {
    var paths: [AstralStageEditorPath] = []
    var activePathIndex: Int?
    var selectedPaths: Set<Int> = [] // Indices of selected paths

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(deleteActivePath(_:)), name: .pathDelete, object: nil)
    }
    
    // Delete active path
    @objc private func deleteActivePath(_ notification: NSNotification) {
        guard let activePathIndex = activePathIndex, let activePath = activePath() else { return }
        var segmentsToDelete = activePath.segments
        func deleteNextSegment() {
            if let segment = segmentsToDelete.first {
                segmentsToDelete.removeFirst()
                segment.animateDeletion {
                    deleteNextSegment()
                }
            } else {
                self.paths.remove(at: activePathIndex)
                self.activePathIndex = nil
            }
        }
        deleteNextSegment()
    }
    
    func updatePathActivation(progress: CGFloat) {
        for path in self.paths {
            if path.isActivated && (progress > CGFloat(path.deactivationProgress) || progress < CGFloat(path.activationProgress)) {
                // print("\(progress)" + " > " + "\(path.deactivationProgress)" + ", hiding")
                path.toggleVisibility(shouldShow: false)
            } else if !path.isActivated && (progress >= CGFloat(path.activationProgress) && progress <= CGFloat(path.deactivationProgress)) {
                // print("\(progress)" + " <= " + "\(path.deactivationProgress)" + ", showing")
                path.toggleVisibility(shouldShow: true)
            }
        }
    }

    
    // Add a new path and set it as the active path
    func addNewPath() -> Int {
        let newPath = AstralStageEditorPath()
        paths.append(newPath)
        activePathIndex = paths.count - 1
        return activePathIndex!
    }
    
    func savePathData(path: AstralStageEditorPath) {
        if let idx = activePathIndex {
            paths[idx].direction = path.direction
            paths[idx].activationProgress = path.activationProgress
            paths[idx].deactivationProgress = path.deactivationProgress
            paths[idx].endBehavior = path.endBehavior
        }
    }

    // Set active path by index
    func setActivePath(index: Int) {
        activePathIndex = index
    }

    // Delete path by index
    func deletePath(at index: Int) {
        paths.remove(at: index)
        // Update selectedPaths set, if needed
    }

    // Select a path by index
    func selectPath(at index: Int) {
        selectedPaths.insert(index)
    }

    // Deselect a path by index
    func deselectPath(at index: Int) {
        selectedPaths.remove(index)
    }

    // Deselect all paths
    func deselectAllPaths() {
        selectedPaths.removeAll()
    }

    // Get the active path
    func activePath() -> AstralStageEditorPath? {
        return activePathIndex != nil ? paths[activePathIndex!] : nil
    }
    
    func getPathIndex(path: AstralStageEditorPath) -> Int? {
         return paths.firstIndex { $0 === path }
     }
    
    /// Retrieves the end point of the last segment of the currently active path.
    /// - Returns: The `CGPoint` representing the end of the last segment if it exists; otherwise, `nil`.
    /// This is particularly useful for continuing to draw a path from where the last segment ended,
    /// ensuring the path's continuity when appending new segments.
    func lastSegmentEndPoint() -> CGPoint? {
        guard let activePath = activePath(), let lastSegment = activePath.segments.last else { return nil }
        switch lastSegment.type {
        case .line(_, let end):
            return end
        case .bezier(_, _, _, let end):
            return end
        }
    }
}
